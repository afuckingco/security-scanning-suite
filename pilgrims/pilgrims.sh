#!/bin/bash
# Strict mode guard (errexit + nounset + pipefail)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/core/strict.sh"
# ============================================================================
# PILGRIMS v17.0 - ULTIMATE SECURITY FRAMEWORK
# ============================================================================

VERSION="17.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_TIME=$(date +%s)

# Load Core
source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/database.sh"
source "$SCRIPT_DIR/core/utils.sh"
source "$SCRIPT_DIR/core/logging.sh"
source "$SCRIPT_DIR/core/stealth_profiles.sh"
source "$SCRIPT_DIR/core/scan_templates.sh"
source "$SCRIPT_DIR/core/themes.sh"
source "$SCRIPT_DIR/core/crypto.sh"
source "$SCRIPT_DIR/core/recorder.sh"
source "$SCRIPT_DIR/core/profiler.sh"
source "$SCRIPT_DIR/core/qr_generator.sh"

init_db
init_logging

# ============================================================================
# CHECK FOR INTERACTIVE MODE (NO ARGUMENTS)
# ============================================================================
if [ $# -eq 0 ]; then
    source "$SCRIPT_DIR/core/interactive_menu.sh"
    interactive_mode
    exit 0
fi

# ============================================================================
# PARSE ARGUMENTS
# ============================================================================
SCAN_TYPE=""
TARGET=""
PROFILE="quick"
STEALTH_PROFILE=""
SCAN_TEMPLATE=""
EXPORT_CSV=0
EXPORT_JSON=0
EXPORT_MD=0
EXPORT_QR=0
ENCRYPT_PASS=""
THEME="default"
SHOW_HISTORY=0
LIST_MODULES=0
SHOW_HELP=0
SHOW_VERSION=0
MODULE_ARGS=""

for arg in "$@"; do
    case $arg in
        # Interactive mode
        --interactive|-i)
            source "$SCRIPT_DIR/core/interactive_menu.sh"
            interactive_mode
            exit 0
            ;;
        
        # Modules
        --module=*) SCAN_TYPE="${arg#*=}" ;;
        --web|--network|--mobile|--cloud|--ad|--container|--code|--wireless|--email|--iot|--binary|--blockchain|--forensic|--redteam|--ics|--medical|--financial|--ai)
            SCAN_TYPE="${arg#--}"
            ;;
        
        # Profiles & Templates
        --profile=*) PROFILE="${arg#*=}" ;;
        --template=*) SCAN_TEMPLATE="${arg#*=}" ;;
        --quick-audit|--full-pentest|--bug-bounty|--compliance|--red-team|--recon-only)
            SCAN_TEMPLATE="${arg#--}"
            ;;
        
        # Stealth
        --stealth|--ghost|--shadow|--phantom|--wraith)
            STEALTH_PROFILE="${arg#--}"
            [ "$STEALTH_PROFILE" == "stealth" ] && STEALTH_PROFILE="phantom"
            ;;
        
        # Exports
        --csv) EXPORT_CSV=1 ;;
        --json) EXPORT_JSON=1 ;;
        --markdown|--md) EXPORT_MD=1 ;;
        --qr) EXPORT_QR=1 ;;
        --encrypt=*) ENCRYPT_PASS="${arg#*=}" ;;
        
        # Theme
        --theme=*) THEME="${arg#*=}" ;;
        --matrix|--blood|--ocean|--mono) THEME="${arg#--}" ;;
        
        # Utilities
        --history) SHOW_HISTORY=1 ;;
        --modules) LIST_MODULES=1 ;;
        --version|-V) SHOW_VERSION=1 ;;
        -h|--help) SHOW_HELP=1 ;;
        
        # Target & other args
        -*) MODULE_ARGS="$MODULE_ARGS $arg" ;;
        *) TARGET="$arg" ;;
    esac
done

apply_theme "$THEME"

# ============================================================================
# HANDLE UTILITIES
if [ "$SHOW_VERSION" -eq 1 ]; then
    echo "PILGRIMS v$VERSION - Ultimate Security Framework"
    echo "License: MIT"
    echo "Repo: https://github.com/afiqandico13/pilgrims-v17"
    exit 0
fi

# ============================================================================
if [ "$SHOW_HELP" -eq 1 ]; then
    print_epic_banner
    echo -e "    ${BOLD}Usage:${NC} ./pilgrims.sh [options] <target>"
    echo ""
    echo -e "    ${BOLD}Interactive Mode:${NC}"
    echo "      ./pilgrims.sh                    # Start interactive menu"
    echo "      ./pilgrims.sh --interactive      # Same as above"
    echo ""
    echo -e "    ${BOLD}Modules:${NC}"
    echo "      --web --network --mobile --cloud --ad --container"
    echo "      --code --wireless --email --iot --binary --blockchain"
    echo "      --forensic --redteam --ics --medical --financial --ai"
    echo ""
    echo -e "    ${BOLD}Profiles:${NC}"
    echo "      --quick (default) --deep --vuln"
    echo ""
    echo -e "    ${BOLD}Templates:${NC}"
    echo "      --quick-audit --full-pentest --bug-bounty"
    echo "      --compliance --red-team --recon-only"
    echo ""
    echo -e "    ${BOLD}Stealth:${NC}"
    echo "      --ghost --shadow --phantom --wraith"
    echo ""
    echo -e "    ${BOLD}Themes:${NC}"
    echo "      --default --matrix --blood --ocean --mono"
    echo ""
    echo -e "    ${BOLD}Export:${NC}"
    echo "      --csv --json --markdown --qr --encrypt=PASS"
    echo ""
    echo -e "    ${BOLD}Utilities:${NC}"
    echo "      --history --modules --help"
    echo ""
    echo -e "    ${BOLD}Examples:${NC}"
    echo "      ./pilgrims.sh                                    # Interactive"
    echo "      ./pilgrims.sh --module=web example.com --quick   # Web scan"
    echo "      ./pilgrims.sh --module=network 192.168.1.1 --deep"
    echo "      ./pilgrims.sh --module=blockchain contract.sol --solidity"
    echo ""
    exit 0
fi

if [ "$SHOW_HISTORY" -eq 1 ]; then
    show_scan_history
    exit 0
fi

if [ "$LIST_MODULES" -eq 1 ]; then
    print_epic_banner
    echo -e "    ${CYAN}🔧 Available Modules:${NC}"
    echo ""
    for m in web network mobile cloud ad container code wireless email iot binary blockchain forensic redteam ics medical financial ai; do
        if [ -f "modules/module-$m/pilgrims-$m.sh" ]; then
            echo -e "    ${GREEN}✓${NC} $m"
        else
            echo -e "    ${YELLOW}⊘${NC} $m"
        fi
    done
    echo ""
    exit 0
fi

# ============================================================================
# APPLY ADVANCED CONFIG
# ============================================================================
[ -n "$SCAN_TEMPLATE" ] && apply_scan_template "$SCAN_TEMPLATE"
[ -n "$STEALTH_PROFILE" ] && apply_stealth_profile "$STEALTH_PROFILE"

# ============================================================================
# VALIDATE
# ============================================================================
if [ -z "$SCAN_TYPE" ]; then
    print_epic_banner
    echo -e "    ${RED}❌ Module not specified${NC}"
    echo ""
    echo -e "    ${BOLD}Quick Start:${NC}"
    echo "      ./pilgrims.sh                              # Interactive mode"
    echo "      ./pilgrims.sh --module=<type> <target>     # Direct scan"
    echo ""
    echo -e "    ${BOLD}Available modules:${NC}"
    echo "      web, network, mobile, cloud, ad, container"
    echo "      code, wireless, email, iot, binary, blockchain"
    echo "      forensic, redteam, ics, medical, financial, ai"
    echo ""
    echo -e "    ${DIM}Run './pilgrims.sh --help' for more info${NC}"
    exit 1
fi

if [ -z "$TARGET" ]; then
    print_epic_banner
    echo -e "    ${RED}❌ Target not specified${NC}"
    echo ""
    echo -e "    ${BOLD}Usage:${NC} ./pilgrims.sh --module=$SCAN_TYPE <target>"
    echo ""
    echo -e "    ${DIM}Example: ./pilgrims.sh --module=$SCAN_TYPE example.com${NC}"
    exit 1
fi

[[ ! "$TARGET" =~ ^https?:// ]] && [[ "$SCAN_TYPE" == "web" || "$SCAN_TYPE" == "email" ]] && TARGET="https://$TARGET"

OUTPUT_DIR="modules/module-$SCAN_TYPE/reports/${SCAN_TYPE}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

start_recording "$OUTPUT_DIR"
log_scan_start "$SCAN_TYPE" "$TARGET"

# Profile target
if [[ "$SCAN_TYPE" =~ ^(web|network|email)$ ]]; then
    PROF_RESULT=$(profile_target "$TARGET")
    echo -e "    ${CYAN}🎯 Target Profile:${NC} $PROF_RESULT"
fi

# ============================================================================
# EXECUTE MODULE
# ============================================================================
MODULE_SCRIPT="modules/module-$SCAN_TYPE/pilgrims-$SCAN_TYPE.sh"
if [ ! -f "$MODULE_SCRIPT" ]; then
    print_error "Module not found: $MODULE_SCRIPT"
    exit 1
fi

print_epic_banner
print_module_info "$SCAN_TYPE" "1.0" "Running with $PROFILE profile"

echo -e "    ${CYAN}Target:${NC} $TARGET"
echo -e "    ${CYAN}Stealth:${NC} ${STEALTH_PROFILE:-Off} | ${CYAN}Theme:${NC} $THEME"
echo -e "    ${CYAN}Export:${NC} $([ $EXPORT_JSON -eq 1 ] && echo "JSON " || echo "")$([ $EXPORT_CSV -eq 1 ] && echo "CSV " || echo "")$([ $EXPORT_QR -eq 1 ] && echo "QR" || echo "None")"
echo ""
echo -e "    ${DIM}Press Enter to start, Ctrl+C to abort...${NC}"
read -r

"$MODULE_SCRIPT" "$TARGET" $MODULE_ARGS
EXIT_CODE=$?

stop_recording "$OUTPUT_DIR"

# Generate exports
[ $EXPORT_QR -eq 1 ] && generate_qr "$TARGET Scan Report" "$OUTPUT_DIR/qr_report"
[ -n "$ENCRYPT_PASS" ] && encrypt_scan "$OUTPUT_DIR" "$ENCRYPT_PASS"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
save_scan_to_db "$SCAN_TYPE" "$TARGET" "$DURATION" "$OUTPUT_DIR"
log_scan_end "$SCAN_TYPE" "$TARGET" "$DURATION" "$(get_total_findings "$OUTPUT_DIR")"

print_mission_complete "$SCAN_TYPE" "$TARGET" "$OUTPUT_DIR" "$DURATION"
exit $EXIT_CODE

# Load new core modules
source "$SCRIPT_DIR/core/resume.sh" 2>/dev/null
source "$SCRIPT_DIR/core/compare.sh" 2>/dev/null
source "$SCRIPT_DIR/core/attack_path.sh" 2>/dev/null
source "$SCRIPT_DIR/core/mitre.sh" 2>/dev/null
source "$SCRIPT_DIR/core/parallel.sh" 2>/dev/null

# Handle new commands in argument parser
for arg in "$@"; do
    case $arg in
        --resume=*)
            RESUME_DIR="${arg#*=}"
            resume_scan "$RESUME_DIR"
            exit 0
            ;;
        --resume-list)
            list_resumable_scans
            exit 0
            ;;
        --compare)
            if [ -n "$SCAN_TYPE" ] && [ -n "$TARGET" ]; then
                compare_scans "$SCAN_TYPE" "$TARGET"
            else
                echo "Usage: $0 --module=<type> <target> --compare"
            fi
            exit 0
            ;;
        --attack-paths)
            if [ -n "$OUTPUT_DIR" ]; then
                map_attack_paths "$OUTPUT_DIR"
            else
                echo "Run a scan first, then use --attack-paths"
            fi
            exit 0
            ;;
        --mitre)
            if [ -n "$OUTPUT_DIR" ]; then
                map_to_mitre "$OUTPUT_DIR"
            else
                echo "Run a scan first, then use --mitre"
            fi
            exit 0
            ;;
        --parallel=*)
            PARALLEL_FILE="${arg#*=}"
            if [ -n "$SCAN_TYPE" ]; then
                parallel_scan "$PARALLEL_FILE" "$SCAN_TYPE" 4
            else
                echo "Usage: $0 --module=<type> --parallel=targets.txt"
            fi
            exit 0
            ;;
    esac
done

# Load new core modules
source "$SCRIPT_DIR/core/resume.sh" 2>/dev/null
source "$SCRIPT_DIR/core/compare.sh" 2>/dev/null
source "$SCRIPT_DIR/core/attack_path.sh" 2>/dev/null
source "$SCRIPT_DIR/core/mitre.sh" 2>/dev/null
source "$SCRIPT_DIR/core/parallel.sh" 2>/dev/null

# Handle new commands in argument parser
for arg in "$@"; do
    case $arg in
        --resume=*)
            RESUME_DIR="${arg#*=}"
            resume_scan "$RESUME_DIR"
            exit 0
            ;;
        --resume-list)
            list_resumable_scans
            exit 0
            ;;
        --compare)
            if [ -n "$SCAN_TYPE" ] && [ -n "$TARGET" ]; then
                compare_scans "$SCAN_TYPE" "$TARGET"
            else
                echo "Usage: $0 --module=<type> <target> --compare"
            fi
            exit 0
            ;;
        --attack-paths)
            if [ -n "$OUTPUT_DIR" ]; then
                map_attack_paths "$OUTPUT_DIR"
            else
                echo "Run a scan first, then use --attack-paths"
            fi
            exit 0
            ;;
        --mitre)
            if [ -n "$OUTPUT_DIR" ]; then
                map_to_mitre "$OUTPUT_DIR"
            else
                echo "Run a scan first, then use --mitre"
            fi
            exit 0
            ;;
        --parallel=*)
            PARALLEL_FILE="${arg#*=}"
            if [ -n "$SCAN_TYPE" ]; then
                parallel_scan "$PARALLEL_FILE" "$SCAN_TYPE" 4
            else
                echo "Usage: $0 --module=<type> --parallel=targets.txt"
            fi
            exit 0
            ;;
    esac
done

# Load advanced testing modules
source "$SCRIPT_DIR/core/fuzzing_advanced.sh" 2>/dev/null
source "$SCRIPT_DIR/core/symbolic.sh" 2>/dev/null
source "$SCRIPT_DIR/core/formal.sh" 2>/dev/null
source "$SCRIPT_DIR/core/mutation.sh" 2>/dev/null

# Handle new commands
for arg in "$@"; do
    case $arg in
        --fuzz=*)
            FUZZ_TARGET="${arg#*=}"
            shift
            FUZZ_INPUT="${1:-seeds/}"
            FUZZ_DURATION="${2:-60}"
            output_dir="reports/fuzzing_$(date +%Y%m%d_%H%M%S)"
            coverage_fuzzing "$FUZZ_TARGET" "$FUZZ_INPUT" "$output_dir" "$FUZZ_DURATION"
            exit 0
            ;;
        --symbolic=*)
            SYMB_TARGET="${arg#*=}"
            output_dir="reports/symbolic_$(date +%Y%m%d_%H%M%S)"
            symbolic_execution "$SYMB_TARGET" "$output_dir"
            exit 0
            ;;
        --formal=*)
            FORMAL_TARGET="${arg#*=}"
            output_dir="reports/formal_$(date +%Y%m%d_%H%M%S)"
            formal_verification "$FORMAL_TARGET" "$output_dir"
            exit 0
            ;;
        --mutation=*)
            MUT_TARGET="${arg#*=}"
            shift
            MUT_TESTS="${1:-tests.txt}"
            output_dir="reports/mutation_$(date +%Y%m%d_%H%M%S)"
            mutation_testing "$MUT_TARGET" "$MUT_TESTS" "$output_dir"
            exit 0
            ;;
    esac
done

# Load Phase 3 modules
source "$SCRIPT_DIR/core/hardware/side_channel.sh" 2>/dev/null
source "$SCRIPT_DIR/core/hardware/fault_injection.sh" 2>/dev/null
source "$SCRIPT_DIR/core/hardware/hsm_test.sh" 2>/dev/null
source "$SCRIPT_DIR/core/hardware/tpm_test.sh" 2>/dev/null
source "$SCRIPT_DIR/core/aiml/llm_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/aiml/federated_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/aiml/backdoor_detection.sh" 2>/dev/null
source "$SCRIPT_DIR/core/aiml/model_stealing.sh" 2>/dev/null
source "$SCRIPT_DIR/core/supplychain/sbom.sh" 2>/dev/null
source "$SCRIPT_DIR/core/supplychain/dependency_confusion.sh" 2>/dev/null
source "$SCRIPT_DIR/core/supplychain/code_signing.sh" 2>/dev/null
source "$SCRIPT_DIR/core/supplychain/container_provenance.sh" 2>/dev/null

# Handle Phase 3 commands
for arg in "$@"; do
    case $arg in
        --side-channel=*)
            SC_TARGET="${arg#*=}"
            shift
            SC_TYPE="${1:-timing}"
            output_dir="reports/side_channel_$(date +%Y%m%d_%H%M%S)"
            side_channel_test "$SC_TARGET" "$output_dir" "$SC_TYPE"
            exit 0
            ;;
        --fault-injection=*)
            FI_TARGET="${arg#*=}"
            output_dir="reports/fault_injection_$(date +%Y%m%d_%H%M%S)"
            fault_injection_test "$FI_TARGET" "$output_dir"
            exit 0
            ;;
        --hsm=*)
            HSM_TARGET="${arg#*=}"
            output_dir="reports/hsm_$(date +%Y%m%d_%H%M%S)"
            hsm_security_test "$HSM_TARGET" "$output_dir"
            exit 0
            ;;
        --tpm=*)
            TPM_TARGET="${arg#*=}"
            output_dir="reports/tpm_$(date +%Y%m%d_%H%M%S)"
            tpm_security_test "$TPM_TARGET" "$output_dir"
            exit 0
            ;;
        --llm=*)
            LLM_TARGET="${arg#*=}"
            output_dir="reports/llm_$(date +%Y%m%d_%H%M%S)"
            llm_security_test "$LLM_TARGET" "$output_dir"
            exit 0
            ;;
        --federated=*)
            FL_TARGET="${arg#*=}"
            output_dir="reports/federated_$(date +%Y%m%d_%H%M%S)"
            federated_learning_test "$FL_TARGET" "$output_dir"
            exit 0
            ;;
        --backdoor=*)
            BD_TARGET="${arg#*=}"
            output_dir="reports/backdoor_$(date +%Y%m%d_%H%M%S)"
            backdoor_detection "$BD_TARGET" "$output_dir"
            exit 0
            ;;
        --model-stealing=*)
            MS_TARGET="${arg#*=}"
            output_dir="reports/model_stealing_$(date +%Y%m%d_%H%M%S)"
            model_stealing_test "$MS_TARGET" "$output_dir"
            exit 0
            ;;
        --sbom=*)
            SBOM_TARGET="${arg#*=}"
            output_dir="reports/sbom_$(date +%Y%m%d_%H%M%S)"
            sbom_analysis "$SBOM_TARGET" "$output_dir"
            exit 0
            ;;
        --dep-confusion=*)
            DC_TARGET="${arg#*=}"
            output_dir="reports/dep_confusion_$(date +%Y%m%d_%H%M%S)"
            dependency_confusion_test "$DC_TARGET" "$output_dir"
            exit 0
            ;;
        --code-signing=*)
            CS_TARGET="${arg#*=}"
            output_dir="reports/code_signing_$(date +%Y%m%d_%H%M%S)"
            code_signing_verification "$CS_TARGET" "$output_dir"
            exit 0
            ;;
        --container-provenance=*)
            CP_TARGET="${arg#*=}"
            output_dir="reports/container_prov_$(date +%Y%m%d_%H%M%S)"
            container_provenance_test "$CP_TARGET" "$output_dir"
            exit 0
            ;;
    esac
done

# Load Phase 4 modules
source "$SCRIPT_DIR/core/cloudnative/ebpf_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/cloudnative/wasm_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/cloudnative/service_mesh.sh" 2>/dev/null
source "$SCRIPT_DIR/core/cloudnative/k8s_admission.sh" 2>/dev/null
source "$SCRIPT_DIR/core/protocol/grpc_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/protocol/quic_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/protocol/websocket_advanced.sh" 2>/dev/null
source "$SCRIPT_DIR/core/protocol/api_gateway.sh" 2>/dev/null
source "$SCRIPT_DIR/core/devsecops/git_hooks.sh" 2>/dev/null
source "$SCRIPT_DIR/core/devsecops/iac_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/devsecops/serverless_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/devsecops/chaos_security.sh" 2>/dev/null

# Handle Phase 4 commands
for arg in "$@"; do
    case $arg in
        --ebpf=*)
            EBPF_TARGET="${arg#*=}"
            output_dir="reports/ebpf_$(date +%Y%m%d_%H%M%S)"
            ebpf_security_analysis "$EBPF_TARGET" "$output_dir"
            exit 0
            ;;
        --wasm=*)
            WASM_TARGET="${arg#*=}"
            output_dir="reports/wasm_$(date +%Y%m%d_%H%M%S)"
            wasm_security_test "$WASM_TARGET" "$output_dir"
            exit 0
            ;;
        --service-mesh=*)
            SM_TARGET="${arg#*=}"
            shift
            SM_TYPE="${1:-istio}"
            output_dir="reports/service_mesh_$(date +%Y%m%d_%H%M%S)"
            service_mesh_test "$SM_TARGET" "$output_dir" "$SM_TYPE"
            exit 0
            ;;
        --k8s-admission=*)
            K8SA_TARGET="${arg#*=}"
            output_dir="reports/k8s_admission_$(date +%Y%m%d_%H%M%S)"
            k8s_admission_test "$K8SA_TARGET" "$output_dir"
            exit 0
            ;;
        --grpc=*)
            GRPC_TARGET="${arg#*=}"
            output_dir="reports/grpc_$(date +%Y%m%d_%H%M%S)"
            grpc_security_test "$GRPC_TARGET" "$output_dir"
            exit 0
            ;;
        --quic=*)
            QUIC_TARGET="${arg#*=}"
            output_dir="reports/quic_$(date +%Y%m%d_%H%M%S)"
            quic_security_test "$QUIC_TARGET" "$output_dir"
            exit 0
            ;;
        --websocket-adv=*)
            WSA_TARGET="${arg#*=}"
            output_dir="reports/websocket_adv_$(date +%Y%m%d_%H%M%S)"
            websocket_advanced_test "$WSA_TARGET" "$output_dir"
            exit 0
            ;;
        --api-gateway=*)
            AG_TARGET="${arg#*=}"
            shift
            AG_TYPE="${1:-kong}"
            output_dir="reports/api_gateway_$(date +%Y%m%d_%H%M%S)"
            api_gateway_test "$AG_TARGET" "$output_dir" "$AG_TYPE"
            exit 0
            ;;
        --git-hooks=*)
            GH_TARGET="${arg#*=}"
            output_dir="reports/git_hooks_$(date +%Y%m%d_%H%M%S)"
            git_hooks_security "$GH_TARGET" "$output_dir"
            exit 0
            ;;
        --iac=*)
            IAC_TARGET="${arg#*=}"
            shift
            IAC_TYPE="${1:-terraform}"
            output_dir="reports/iac_$(date +%Y%m%d_%H%M%S)"
            iac_security_test "$IAC_TARGET" "$output_dir" "$IAC_TYPE"
            exit 0
            ;;
        --serverless=*)
            SL_TARGET="${arg#*=}"
            shift
            SL_PROVIDER="${1:-aws}"
            output_dir="reports/serverless_$(date +%Y%m%d_%H%M%S)"
            serverless_security_test "$SL_TARGET" "$output_dir" "$SL_PROVIDER"
            exit 0
            ;;
        --chaos=*)
            CHAOS_TARGET="${arg#*=}"
            output_dir="reports/chaos_$(date +%Y%m%d_%H%M%S)"
            chaos_security_test "$CHAOS_TARGET" "$output_dir"
            exit 0
            ;;
    esac
done

# Load Phase 3 modules
source "$SCRIPT_DIR/core/hardware/side_channel.sh" 2>/dev/null
source "$SCRIPT_DIR/core/hardware/fault_injection.sh" 2>/dev/null
source "$SCRIPT_DIR/core/hardware/hsm_test.sh" 2>/dev/null
source "$SCRIPT_DIR/core/hardware/tpm_test.sh" 2>/dev/null
source "$SCRIPT_DIR/core/aiml/llm_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/aiml/federated_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/aiml/backdoor_detection.sh" 2>/dev/null
source "$SCRIPT_DIR/core/aiml/model_stealing.sh" 2>/dev/null
source "$SCRIPT_DIR/core/supplychain/sbom.sh" 2>/dev/null
source "$SCRIPT_DIR/core/supplychain/dependency_confusion.sh" 2>/dev/null
source "$SCRIPT_DIR/core/supplychain/code_signing.sh" 2>/dev/null
source "$SCRIPT_DIR/core/supplychain/container_provenance.sh" 2>/dev/null

# Handle Phase 3 commands
for arg in "$@"; do
    case $arg in
        --side-channel=*)
            SC_TARGET="${arg#*=}"
            shift
            SC_TYPE="${1:-timing}"
            output_dir="reports/side_channel_$(date +%Y%m%d_%H%M%S)"
            side_channel_test "$SC_TARGET" "$output_dir" "$SC_TYPE"
            exit 0
            ;;
        --fault-injection=*)
            FI_TARGET="${arg#*=}"
            output_dir="reports/fault_injection_$(date +%Y%m%d_%H%M%S)"
            fault_injection_test "$FI_TARGET" "$output_dir"
            exit 0
            ;;
        --hsm=*)
            HSM_TARGET="${arg#*=}"
            output_dir="reports/hsm_$(date +%Y%m%d_%H%M%S)"
            hsm_security_test "$HSM_TARGET" "$output_dir"
            exit 0
            ;;
        --tpm=*)
            TPM_TARGET="${arg#*=}"
            output_dir="reports/tpm_$(date +%Y%m%d_%H%M%S)"
            tpm_security_test "$TPM_TARGET" "$output_dir"
            exit 0
            ;;
        --llm=*)
            LLM_TARGET="${arg#*=}"
            output_dir="reports/llm_$(date +%Y%m%d_%H%M%S)"
            llm_security_test "$LLM_TARGET" "$output_dir"
            exit 0
            ;;
        --federated=*)
            FL_TARGET="${arg#*=}"
            output_dir="reports/federated_$(date +%Y%m%d_%H%M%S)"
            federated_learning_test "$FL_TARGET" "$output_dir"
            exit 0
            ;;
        --backdoor=*)
            BD_TARGET="${arg#*=}"
            output_dir="reports/backdoor_$(date +%Y%m%d_%H%M%S)"
            backdoor_detection "$BD_TARGET" "$output_dir"
            exit 0
            ;;
        --model-stealing=*)
            MS_TARGET="${arg#*=}"
            output_dir="reports/model_stealing_$(date +%Y%m%d_%H%M%S)"
            model_stealing_test "$MS_TARGET" "$output_dir"
            exit 0
            ;;
        --sbom=*)
            SBOM_TARGET="${arg#*=}"
            output_dir="reports/sbom_$(date +%Y%m%d_%H%M%S)"
            sbom_analysis "$SBOM_TARGET" "$output_dir"
            exit 0
            ;;
        --dep-confusion=*)
            DC_TARGET="${arg#*=}"
            output_dir="reports/dep_confusion_$(date +%Y%m%d_%H%M%S)"
            dependency_confusion_test "$DC_TARGET" "$output_dir"
            exit 0
            ;;
        --code-signing=*)
            CS_TARGET="${arg#*=}"
            output_dir="reports/code_signing_$(date +%Y%m%d_%H%M%S)"
            code_signing_verification "$CS_TARGET" "$output_dir"
            exit 0
            ;;
        --container-provenance=*)
            CP_TARGET="${arg#*=}"
            output_dir="reports/container_prov_$(date +%Y%m%d_%H%M%S)"
            container_provenance_test "$CP_TARGET" "$output_dir"
            exit 0
            ;;
    esac
done

# Load Phase 5 modules
source "$SCRIPT_DIR/core/compliance/soc2.sh" 2>/dev/null
source "$SCRIPT_DIR/core/compliance/iso27001.sh" 2>/dev/null
source "$SCRIPT_DIR/core/compliance/hipaa.sh" 2>/dev/null
source "$SCRIPT_DIR/core/compliance/pcidss.sh" 2>/dev/null
source "$SCRIPT_DIR/core/crypto/zkp_audit.sh" 2>/dev/null
source "$SCRIPT_DIR/core/crypto/pqc_test.sh" 2>/dev/null
source "$SCRIPT_DIR/core/crypto/mpc_security.sh" 2>/dev/null
source "$SCRIPT_DIR/core/crypto/fhe_audit.sh" 2>/dev/null
source "$SCRIPT_DIR/core/threatintel/mitre_navigator.sh" 2>/dev/null
source "$SCRIPT_DIR/core/threatintel/stix_taxii.sh" 2>/dev/null
source "$SCRIPT_DIR/core/threatintel/soar_integration.sh" 2>/dev/null
source "$SCRIPT_DIR/core/threatintel/ir_automation.sh" 2>/dev/null

# Handle Phase 5 commands
for arg in "$@"; do
    case $arg in
        --soc2=*)
            SOC2_TARGET="${arg#*=}"
            output_dir="reports/soc2_$(date +%Y%m%d_%H%M%S)"
            soc2_compliance_check "$SOC2_TARGET" "$output_dir"
            exit 0
            ;;
        --iso27001=*)
            ISO_TARGET="${arg#*=}"
            output_dir="reports/iso27001_$(date +%Y%m%d_%H%M%S)"
            iso27001_assessment "$ISO_TARGET" "$output_dir"
            exit 0
            ;;
        --hipaa=*)
            HIPAA_TARGET="${arg#*=}"
            output_dir="reports/hipaa_$(date +%Y%m%d_%H%M%S)"
            hipaa_audit "$HIPAA_TARGET" "$output_dir"
            exit 0
            ;;
        --pcidss=*)
            PCI_TARGET="${arg#*=}"
            output_dir="reports/pcidss_$(date +%Y%m%d_%H%M%S)"
            pcidss_scan "$PCI_TARGET" "$output_dir"
            exit 0
            ;;
        --zkp=*)
            ZKP_TARGET="${arg#*=}"
            output_dir="reports/zkp_$(date +%Y%m%d_%H%M%S)"
            zkp_audit "$ZKP_TARGET" "$output_dir"
            exit 0
            ;;
        --pqc=*)
            PQC_TARGET="${arg#*=}"
            output_dir="reports/pqc_$(date +%Y%m%d_%H%M%S)"
            pqc_testing "$PQC_TARGET" "$output_dir"
            exit 0
            ;;
        --mpc=*)
            MPC_TARGET="${arg#*=}"
            output_dir="reports/mpc_$(date +%Y%m%d_%H%M%S)"
            mpc_security "$MPC_TARGET" "$output_dir"
            exit 0
            ;;
        --fhe=*)
            FHE_TARGET="${arg#*=}"
            output_dir="reports/fhe_$(date +%Y%m%d_%H%M%S)"
            fhe_audit "$FHE_TARGET" "$output_dir"
            exit 0
            ;;
        --mitre-nav=*)
            MITRE_TARGET="${arg#*=}"
            output_dir="reports/mitre_nav_$(date +%Y%m%d_%H%M%S)"
            mitre_navigator "$MITRE_TARGET" "$output_dir"
            exit 0
            ;;
        --stix=*)
            STIX_TARGET="${arg#*=}"
            output_dir="reports/stix_$(date +%Y%m%d_%H%M%S)"
            stix_taxii_integration "$STIX_TARGET" "$output_dir"
            exit 0
            ;;
        --soar=*)
            SOAR_TARGET="${arg#*=}"
            output_dir="reports/soar_$(date +%Y%m%d_%H%M%S)"
            soar_integration "$SOAR_TARGET" "$output_dir"
            exit 0
            ;;
        --ir=*)
            IR_TARGET="${arg#*=}"
            output_dir="reports/ir_$(date +%Y%m%d_%H%M%S)"
            ir_automation "$IR_TARGET" "$output_dir"
            exit 0
            ;;
    esac
done
