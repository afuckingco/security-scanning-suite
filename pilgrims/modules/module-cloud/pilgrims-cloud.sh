#!/bin/bash

# ============================================================================
# PILGRIMS-CLOUD - Cloud Security Assessment Module
# ============================================================================

MODULE_NAME="cloud"
MODULE_VERSION="1.0"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../core/ui.sh"
source "$SCRIPT_DIR/../../core/utils.sh"
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module - run it as a script" >&2; return 0 2>/dev/null || exit 0; }

# Parse arguments
PROVIDER=""
PROFILE="full"
TARGET="$1"

shift
for arg in "$@"; do
    case $arg in
        --provider=*) PROVIDER="${arg#*=}" ;;
        --aws) PROVIDER="aws" ;;
        --azure) PROVIDER="azure" ;;
        --gcp) PROVIDER="gcp" ;;
        --quick) PROFILE="quick" ;;
        --deep) PROFILE="deep" ;;
    esac
done

if [ -z "$PROVIDER" ]; then
    print_error "Provider not specified. Use --aws, --azure, or --gcp"
    exit 1
fi

OUTPUT_DIR="$MODULE_DIR/reports/cloud_$(get_timestamp)"
mkdir -p "$OUTPUT_DIR"

print_phase_header "CLOUD" "☁️  CLOUD SECURITY ASSESSMENT - $PROVIDER"
print_info "Provider: $PROVIDER"
print_info "Profile: $PROFILE"
echo ""

# ============================================================================
# AWS ASSESSMENT
# ============================================================================
if [ "$PROVIDER" = "aws" ]; then
    print_phase_header "1" "🔐 AWS IAM ANALYSIS"
    print_task "Checking IAM users and roles"
    
    if command_exists aws; then
        # List IAM users
        aws iam list-users --query 'Users[*].[UserName,CreateDate]' --output table > "$OUTPUT_DIR/iam_users.txt" 2>&1
        USERS=$(wc -l < "$OUTPUT_DIR/iam_users.txt")
        print_success "Found $USERS IAM users"
        
        # Check for users without MFA
        print_task "Checking MFA status"
        aws iam generate-credential-report > /dev/null 2>&1
        sleep 5
        aws iam get-credential-report --query 'Content' --output text | base64 -d > "$OUTPUT_DIR/credential_report.csv" 2>&1
        
        NO_MFA=$(grep -c ",false," "$OUTPUT_DIR/credential_report.csv" 2>/dev/null || echo "0")
        if [ $NO_MFA -gt 0 ]; then
            print_critical "$NO_MFA users without MFA"
            echo "[CRITICAL] $NO_MFA IAM users without MFA" > "$OUTPUT_DIR/mfa_findings.txt"
        fi
        
        # S3 Bucket Analysis
        print_phase_header "2" "📦 S3 BUCKET ANALYSIS"
        print_task "Listing S3 buckets"
        
        aws s3api list-buckets --query 'Buckets[*].Name' --output text > "$OUTPUT_DIR/s3_buckets.txt" 2>&1
        BUCKETS=$(wc -w < "$OUTPUT_DIR/s3_buckets.txt")
        print_success "Found $BUCKETS S3 buckets"
        
        print_task "Checking bucket policies"
        > "$OUTPUT_DIR/public_buckets.txt"
        
        while read -r bucket; do
            # Check public access
            public=$(aws s3api get-public-access-block --bucket "$bucket" 2>&1)
            if echo "$public" | grep -q "false"; then
                echo "[HIGH] Public bucket: $bucket" >> "$OUTPUT_DIR/public_buckets.txt"
                print_vuln "HIGH" "Public bucket: $bucket"
            fi
        done < <(cat "$OUTPUT_DIR/s3_buckets.txt" | tr '\t' '\n' | grep -v "^$")
        
        # EC2 Security Groups
        print_phase_header "3" "🔒 EC2 SECURITY GROUPS"
        print_task "Analyzing security groups"
        
        aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName,IpPermissions]' --output json > "$OUTPUT_DIR/security_groups.json" 2>&1
        
        # Check for overly permissive rules
        OPEN_TO_WORLD=$(jq '[.[] | select(.IpPermissions[] | select(.IpRanges[]?.CidrIp == "0.0.0.0/0"))] | length' "$OUTPUT_DIR/security_groups.json" 2>/dev/null || echo "0")
        
        if [ $OPEN_TO_WORLD -gt 0 ]; then
            print_critical "$OPEN_TO_WORLD security groups open to world"
            echo "[CRITICAL] $OPEN_TO_WORLD security groups open to 0.0.0.0/0" > "$OUTPUT_DIR/sg_findings.txt"
        fi
        
    else
        print_error "AWS CLI not installed"
        print_info "Install with: sudo apt install awscli"
    fi
fi

# ============================================================================
# AZURE ASSESSMENT
# ============================================================================
if [ "$PROVIDER" = "azure" ]; then
    print_phase_header "1" "🔐 AZURE AD ANALYSIS"
    print_task "Checking Azure AD users"
    
    if command_exists az; then
        az ad user list --query '[].[userPrincipalName,accountEnabled]' --output table > "$OUTPUT_DIR/ad_users.txt" 2>&1
        print_success "Azure AD users enumerated"
        
        # Storage Accounts
        print_phase_header "2" "📦 STORAGE ACCOUNTS"
        print_task "Analyzing storage accounts"
        
        az storage account list --query '[].[name,primaryEndpoints]' --output table > "$OUTPUT_DIR/storage_accounts.txt" 2>&1
        
        # Check for public access
        # shellcheck disable=SC2016  # Azure --query syntax literal
        az storage account list --query '[?allowBlobPublicAccess==`true`].[name]' --output tsv > "$OUTPUT_DIR/public_storage.txt" 2>&1
        
        PUBLIC_STORAGE=$(wc -l < "$OUTPUT_DIR/public_storage.txt")
        if [ $PUBLIC_STORAGE -gt 0 ]; then
            print_critical "$PUBLIC_STORAGE storage accounts with public blob access"
            echo "[CRITICAL] $PUBLIC_STORAGE storage accounts with public access" > "$OUTPUT_DIR/storage_findings.txt"
        fi
        
    else
        print_error "Azure CLI not installed"
        print_info "Install with: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    fi
fi

# ============================================================================
# GCP ASSESSMENT
# ============================================================================
if [ "$PROVIDER" = "gcp" ]; then
    print_phase_header "1" "🔐 GCP IAM ANALYSIS"
    print_task "Checking GCP IAM bindings"
    
    if command_exists gcloud; then
        gcloud iam service-accounts list --format="table(email,disabled)" > "$OUTPUT_DIR/service_accounts.txt" 2>&1
        print_success "Service accounts enumerated"
        
        # Storage Buckets
        print_phase_header "2" "📦 GCS BUCKETS"
        print_task "Analyzing GCS buckets"
        
        gsutil ls > "$OUTPUT_DIR/gcs_buckets.txt" 2>&1
        
        # Check for public access
        > "$OUTPUT_DIR/public_buckets.txt"
        while read -r bucket; do
            acl=$(gsutil iam get "$bucket" 2>&1)
            if echo "$acl" | grep -q "allUsers"; then
                echo "[HIGH] Public bucket: $bucket" >> "$OUTPUT_DIR/public_buckets.txt"
                print_vuln "HIGH" "Public bucket: $bucket"
            fi
        done < "$OUTPUT_DIR/gcs_buckets.txt"
        
    else
        print_error "GCP SDK not installed"
        print_info "Install from: https://cloud.google.com/sdk/docs/install"
    fi
fi

# Generate report
print_phase_header "REPORT" "📊 GENERATING REPORT"

cat > "$OUTPUT_DIR/REPORT.md" << EOF
# ☁️ Cloud Security Assessment Report

**Provider:** $PROVIDER  
**Date:** $(date)  
**Profile:** $PROFILE

## 📊 Summary

$(cat "$OUTPUT_DIR"/*.txt 2>/dev/null | grep -E "\[CRITICAL\]|\[HIGH\]" | head -20)

## 📁 Files Generated

$(find "$OUTPUT_DIR" -maxdepth 1 -type f -printf "%f
" 2>/dev/null | grep -v "^REPORT\.md$")

## 🛡️ Recommendations

- Enable MFA for all users
- Restrict public access to storage
- Review security group rules
- Implement least privilege access
- Enable logging and monitoring
EOF

print_success "Report: $OUTPUT_DIR/REPORT.md"
