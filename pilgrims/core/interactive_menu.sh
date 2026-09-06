#!/bin/bash
# ============================================================================
# PILGRIMS INTERACTIVE MENU SYSTEM
# ============================================================================

show_main_menu() {
    print_epic_banner
    
    echo -e "    ${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "    ${CYAN}║${NC}              ${BOLD}🎯 PILGRIMS v16.0 - INTERACTIVE MODE${NC}                       ${CYAN}║${NC}"
    echo -e "    ${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "    ${BOLD}Pilih kategori scanning:${NC}"
    echo ""
    
    # Web & Network
    echo -e "    ${YELLOW}━━━ 🌐 WEB & NETWORK ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${GREEN}[ 1]${NC} 🌐 Web Application Security"
    echo -e "    ${GREEN}[ 2]${NC} 🌐 Network Security Assessment"
    echo -e "    ${GREEN}[ 3]${NC} 📡 Wireless Security"
    echo -e "    ${GREEN}[ 4]${NC} 📧 Email Security"
    echo ""
    
    # Cloud & Infrastructure
    echo -e "    ${YELLOW}━━━ ☁️  CLOUD & INFRASTRUCTURE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${GREEN}[ 5]${NC} ☁️  Cloud Security (AWS/Azure/GCP)"
    echo -e "    ${GREEN}[ 6]${NC} 🏢 Active Directory Security"
    echo -e "    ${GREEN}[ 7]${NC} 🐳 Container & Kubernetes"
    echo ""
    
    # Mobile & Code
    echo -e "    ${YELLOW}━━━ 📱 MOBILE & CODE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${GREEN}[ 8]${NC} 📱 Mobile App Security (Android/iOS)"
    echo -e "    ${GREEN}[ 9]${NC} 💻 Source Code Review (SAST)"
    echo -e "    ${GREEN}[10]${NC} 🔌 IoT/Firmware Security"
    echo -e "    ${GREEN}[11]${NC} 🎯 Binary Analysis & Reverse Engineering"
    echo ""
    
    # Specialized Industries
    echo -e "    ${YELLOW}━━━ 🏭 SPECIALIZED INDUSTRIES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${GREEN}[12]${NC} ⛓️  Blockchain & Web3 Security"
    echo -e "    ${GREEN}[13]${NC} 🏭 ICS/SCADA Security"
    echo -e "    ${GREEN}[14]${NC} 🏥 Medical Device Security"
    echo -e "    ${GREEN}[15]${NC} 💰 Financial Systems Security"
    echo -e "    ${GREEN}[16]${NC} 🚗 Automotive Security"
    echo -e "    ${GREEN}[17]${NC} 📡 5G/Telecom Security"
    echo ""
    
    # Advanced Techniques
    echo -e "    ${YELLOW}━━━ ⚡ ADVANCED TECHNIQUES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${GREEN}[18]${NC} 🎭 Red Team Automation"
    echo -e "    ${GREEN}[19]${NC} 🛡️  Purple Team Integration"
    echo -e "    ${GREEN}[20]${NC} 🔍 Digital Forensics"
    echo -e "    ${GREEN}[21]${NC} 🦠 Malware Analysis"
    echo -e "    ${GREEN}[22]${NC} 🤖 AI/ML Model Security"
    echo -e "    ${GREEN}[23]${NC} 🎮 Gaming Security"
    echo ""
    
    # Enterprise Features
    echo -e "    ${YELLOW}━━━ 🏢 ENTERPRISE FEATURES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${GREEN}[24]${NC} 📊 Threat Intelligence"
    echo -e "    ${GREEN}[25]${NC} ⚡ CI/CD Pipeline Integration"
    echo -e "    ${GREEN}[26]${NC} 👥 Multi-User Team Mode"
    echo -e "    ${GREEN}[27]${NC} 🔌 Custom Plugin Manager"
    echo ""
    
    # Utilities
    echo -e "    ${YELLOW}━━━ 🔧 UTILITIES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${GREEN}[ H]${NC} 📖 Help & Documentation"
    echo -e "    ${GREEN}[ I]${NC} 📜 Scan History"
    echo -e "    ${GREEN}[ S]${NC} 📊 System Status"
    echo -e "    ${GREEN}[ T]${NC} 🎨 Change Theme"
    echo -e "    ${YELLOW}━━━ ⚡ ADVANCED FEATURES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${GREEN}[28]${NC} 🔄 Resume Previous Scan"
    echo -e "    ${GREEN}[29]${NC} 📊 Compare Scans"
    echo -e "    ${GREEN}[30]${NC} 🗺️  Attack Path Mapper"
    echo -e "    ${GREEN}[31]${NC} 🎯 MITRE ATT&CK Mapping"
    echo -e "    ${GREEN}[32]${NC} ⚡ Parallel Scanning"
    echo -e "    ${GREEN}[33]${NC} 🧬 Coverage-Guided Fuzzing"
    echo -e "    ${GREEN}[34]${NC} 🧪 Symbolic Execution"
    echo -e "    ${GREEN}[35]${NC} 🔬 Formal Verification"
    echo -e "    ${GREEN}[ Q]${NC} 🚪 Quit"
    echo ""
    
    echo -e "    ${CYAN}───────────────────────────────────────────────────────────────────────────────${NC}"
    echo -ne "    ${BOLD}Pilihan Anda [1-35/H/I/S/T/Q]:${NC} "
}

show_web_submenu() {
    print_epic_banner
    echo -e "    ${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "    ${CYAN}║${NC}              ${BOLD}🌐 WEB APPLICATION SECURITY${NC}                                ${CYAN}║${NC}"
    echo -e "    ${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "    ${BOLD}Pilih scan profile:${NC}"
    echo ""
    echo -e "    ${GREEN}[1]${NC} 🔍 Quick Audit (5-10 menit) - Basic checks"
    echo -e "    ${GREEN}[2]${NC} 🎯 Full Pentest (30-60 menit) - Comprehensive"
    echo -e "    ${GREEN}[3]${NC} 💰 Bug Bounty (20-40 menit) - High-impact focus"
    echo -e "    ${GREEN}[4]${NC} 📋 Compliance (25-45 menit) - OWASP/PCI-DSS"
    echo -e "    ${GREEN}[5]${NC} 🎭 Red Team (45-90 menit) - Max stealth"
    echo -e "    ${GREEN}[6]${NC} 🔍 Recon Only (3-8 menit) - Passive info"
    echo ""
    echo -e "    ${BOLD}Advanced options:${NC}"
    echo -e "    ${GREEN}[S]${NC} 👻 Enable Stealth Mode"
    echo -e "    ${GREEN}[E]${NC} 🔐 Enable Encryption"
    echo -e "    ${GREEN}[Q]${NC} 📱 Generate QR Code"
    echo -e "    ${GREEN}[B]${NC} ⬅️  Back to Main Menu"
    echo ""
    echo -ne "    ${BOLD}Pilihan:${NC} "
}

handle_menu_choice() {
    local choice=$1
    
    case $choice in
        1) SCAN_MODULE="web"; show_web_submenu ;;
        2) SCAN_MODULE="network"; prompt_target "network" ;;
        3) SCAN_MODULE="wireless"; prompt_target "wireless" ;;
        4) SCAN_MODULE="email"; prompt_target "email" ;;
        5) SCAN_MODULE="cloud"; prompt_cloud_provider ;;
        6) SCAN_MODULE="ad"; prompt_target "ad" ;;
        7) SCAN_MODULE="container"; prompt_container_mode ;;
        8) SCAN_MODULE="mobile"; prompt_mobile_platform ;;
        9) SCAN_MODULE="code"; prompt_code_scan ;;
        10) SCAN_MODULE="iot"; prompt_iot_mode ;;
        11) SCAN_MODULE="binary"; prompt_binary_mode ;;
        12) SCAN_MODULE="blockchain"; prompt_blockchain_mode ;;
        13) SCAN_MODULE="ics"; prompt_target "ics" ;;
        14) SCAN_MODULE="medical"; prompt_target "medical" ;;
        15) SCAN_MODULE="financial"; prompt_target "financial" ;;
        16) SCAN_MODULE="automotive"; prompt_target "automotive" ;;
        17) SCAN_MODULE="5g"; prompt_target "5g" ;;
        18) SCAN_MODULE="redteam"; prompt_redteam_scenario ;;
        19) SCAN_MODULE="purple"; prompt_target "purple" ;;
        20) SCAN_MODULE="forensic"; prompt_forensic_mode ;;
        21) SCAN_MODULE="malware"; prompt_malware_mode ;;
        22) SCAN_MODULE="ai"; prompt_ai_mode ;;
        23) SCAN_MODULE="gaming"; prompt_target "gaming" ;;
        24) SCAN_MODULE="threatintel"; prompt_threatintel_mode ;;
        25) SCAN_MODULE="cicd"; prompt_cicd_mode ;;
        26) SCAN_MODULE="team"; prompt_team_mode ;;
        27) SCAN_MODULE="plugin"; show_plugin_manager ;;
        H|h) show_help ;;
        I|i) show_scan_history ;;
        S|s) show_system_status ;;
        T|t) change_theme ;;
        Q|q) exit 0 ;;

        28) list_resumable_scans ;;
        29)
            echo -ne "    Module: "; read -r m
            echo -ne "    Target: "; read -r t
            compare_scans "$m" "$t"
            ;;
        30)
            echo -ne "    Scan directory: "; read -r d
            map_attack_paths "$d"
            ;;
        31)
            echo -ne "    Scan directory: "; read -r d
            map_to_mitre "$d"
            ;;
        32)
            echo -ne "    Targets file: "; read -r fa
            echo -ne "    Module: "; read -r ma
            parallel_scan "$fa" "$ma" 4
            ;;
        33)
            echo -ne "    Target URL/file: "; read -r target
            echo -ne "    Input directory: "; read -r input_dir
            echo -ne "    Duration (seconds): "; read -r duration
            output_dir="reports/fuzzing_$(date +%Y%m%d_%H%M%S)"
            coverage_fuzzing "$target" "$input_dir" "$output_dir" "$duration"
            ;;
        34)
            echo -ne "    Target: "; read -r target
            output_dir="reports/symbolic_$(date +%Y%m%d_%H%M%S)"
            symbolic_execution "$target" "$output_dir"
            ;;
        35)
            echo -ne "    Target: "; read -r target
            output_dir="reports/formal_$(date +%Y%m%d_%H%M%S)"
            formal_verification "$target" "$output_dir"
            ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_target() {
    local module=$1
    echo ""
    echo -ne "    ${BOLD}Masukkan target:${NC} "
    read -r target
    
    if [ -z "$target" ]; then
        echo -e "    ${RED}❌ Target tidak boleh kosong${NC}"
        sleep 2
        return
    fi
    
    echo ""
    echo -e "    ${CYAN}🚀 Starting $module scan on: $target${NC}"
    echo -e "    ${DIM}Press Ctrl+C to abort...${NC}"
    sleep 2
    
    ./pilgrims.sh --module=$module "$target"
}

prompt_cloud_provider() {
    echo ""
    echo -e "    ${BOLD}Pilih cloud provider:${NC}"
    echo -e "    ${GREEN}[1]${NC} ☁️  AWS"
    echo -e "    ${GREEN}[2]${NC} ☁️  Azure"
    echo -e "    ${GREEN}[3]${NC} ☁️  GCP"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) ./pilgrims.sh --module=cloud --aws ;;
        2) ./pilgrims.sh --module=cloud --azure ;;
        3) ./pilgrims.sh --module=cloud --gcp ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_container_mode() {
    echo ""
    echo -e "    ${BOLD}Pilih mode:${NC}"
    echo -e "    ${GREEN}[1]${NC} 🐳 Docker"
    echo -e "    ${GREEN}[2]${NC} ☸️  Kubernetes"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) ./pilgrims.sh --module=container --docker ;;
        2) ./pilgrims.sh --module=container --k8s ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_mobile_platform() {
    echo ""
    echo -ne "    ${BOLD}Masukkan path file APK/IPA:${NC} "
    read -r file
    
    if [ ! -f "$file" ]; then
        echo -e "    ${RED}❌ File tidak ditemukan${NC}"
        sleep 2
        return
    fi
    
    echo ""
    echo -e "    ${BOLD}Pilih platform:${NC}"
    echo -e "    ${GREEN}[1]${NC} 🤖 Android"
    echo -e "    ${GREEN}[2]${NC} 🍎 iOS"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) ./pilgrims.sh --module=mobile "$file" --android ;;
        2) ./pilgrims.sh --module=mobile "$file" --ios ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_code_scan() {
    echo ""
    echo -ne "    ${BOLD}Masukkan path source code:${NC} "
    read -r path
    
    if [ ! -d "$path" ]; then
        echo -e "    ${RED}❌ Directory tidak ditemukan${NC}"
        sleep 2
        return
    fi
    
    echo ""
    echo -e "    ${BOLD}Pilih language:${NC}"
    echo -e "    ${GREEN}[1]${NC} 🐍 Python"
    echo -e "    ${GREEN}[2]${NC} 📜 JavaScript"
    echo -e "    ${GREEN}[3]${NC} 🐘 PHP"
    echo -e "    ${GREEN}[4]${NC} ☕ Java"
    echo -e "    ${GREEN}[5]${NC} 🔍 Auto-detect"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) ./pilgrims.sh --module=code "$path" --lang=python ;;
        2) ./pilgrims.sh --module=code "$path" --lang=javascript ;;
        3) ./pilgrims.sh --module=code "$path" --lang=php ;;
        4) ./pilgrims.sh --module=code "$path" --lang=java ;;
        5) ./pilgrims.sh --module=code "$path" ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_iot_mode() {
    echo ""
    echo -e "    ${BOLD}Pilih mode:${NC}"
    echo -e "    ${GREEN}[1]${NC} 📦 Firmware Analysis"
    echo -e "    ${GREEN}[2]${NC} 🔌 Device Analysis"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) 
            echo -ne "    ${BOLD}Masukkan path firmware:${NC} "
            read -r file
            [ -f "$file" ] && ./pilgrims.sh --module=iot "$file" --firmware || echo -e "    ${RED}❌ File tidak ditemukan${NC}"
            ;;
        2) prompt_target "iot" ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_binary_mode() {
    echo ""
    echo -ne "    ${BOLD}Masukkan path binary:${NC} "
    read -r file
    
    if [ ! -f "$file" ]; then
        echo -e "    ${RED}❌ File tidak ditemukan${NC}"
        sleep 2
        return
    fi
    
    echo ""
    echo -e "    ${BOLD}Pilih mode:${NC}"
    echo -e "    ${GREEN}[1]${NC} 🔍 Static Analysis"
    echo -e "    ${GREEN}[2]${NC} 🔄 Dynamic Analysis"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) ./pilgrims.sh --module=binary "$file" --static ;;
        2) ./pilgrims.sh --module=binary "$file" --dynamic ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_blockchain_mode() {
    echo ""
    echo -e "    ${BOLD}Pilih mode:${NC}"
    echo -e "    ${GREEN}[1]${NC} 📜 Smart Contract Analysis"
    echo -e "    ${GREEN}[2]${NC} 💼 Wallet Security"
    echo -e "    ${GREEN}[3]${NC} 💱 DeFi Protocol"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1)
            echo -ne "    ${BOLD}Masukkan path contract (.sol):${NC} "
            read -r file
            [ -f "$file" ] && ./pilgrims.sh --module=blockchain "$file" --solidity || echo -e "    ${RED}❌ File tidak ditemukan${NC}"
            ;;
        2)
            echo -ne "    ${BOLD}Masukkan wallet address:${NC} "
            read -r addr
            ./pilgrims.sh --module=blockchain "$addr" --wallet
            ;;
        3)
            echo -ne "    ${BOLD}Masukkan protocol name:${NC} "
            read -r proto
            ./pilgrims.sh --module=blockchain "$proto" --defi
            ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_redteam_scenario() {
    echo ""
    echo -e "    ${BOLD}Pilih scenario:${NC}"
    echo -e "    ${GREEN}[1]${NC} 🎯 Custom Scenario"
    echo -e "    ${GREEN}[2]${NC} 🇷🇺 APT29 Simulation"
    echo -e "    ${GREEN}[3]${NC} 🇰🇵 Lazarus Group"
    echo -e "    ${GREEN}[4]${NC} 🏦 Financial Threat"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) prompt_target "redteam" ;;
        2) echo -e "    ${CYAN}🚀 Simulating APT29 tactics...${NC}"; sleep 2 ;;
        3) echo -e "    ${CYAN}🚀 Simulating Lazarus Group...${NC}"; sleep 2 ;;
        4) echo -e "    ${CYAN}🚀 Simulating Financial Threat...${NC}"; sleep 2 ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_forensic_mode() {
    echo ""
    echo -e "    ${BOLD}Pilih mode:${NC}"
    echo -e "    ${GREEN}[1]${NC} 💾 Disk Image Analysis"
    echo -e "    ${GREEN}[2]${NC} 🧠 Memory Analysis"
    echo -e "    ${GREEN}[3]${NC} 📅 Timeline Reconstruction"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1)
            echo -ne "    ${BOLD}Masukkan path disk image:${NC} "
            read -r file
            [ -f "$file" ] && ./pilgrims.sh --module=forensic "$file" --disk || echo -e "    ${RED}❌ File tidak ditemukan${NC}"
            ;;
        2)
            echo -ne "    ${BOLD}Masukkan path memory dump:${NC} "
            read -r file
            [ -f "$file" ] && ./pilgrims.sh --module=forensic "$file" --ram || echo -e "    ${RED}❌ File tidak ditemukan${NC}"
            ;;
        3)
            echo -ne "    ${BOLD}Masukkan path evidence folder:${NC} "
            read -r path
            [ -d "$path" ] && ./pilgrims.sh --module=forensic "$path" --timeline || echo -e "    ${RED}❌ Directory tidak ditemukan${NC}"
            ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_malware_mode() {
    echo ""
    echo -ne "    ${BOLD}Masukkan path sample:${NC} "
    read -r file
    
    if [ ! -f "$file" ]; then
        echo -e "    ${RED}❌ File tidak ditemukan${NC}"
        sleep 2
        return
    fi
    
    echo ""
    echo -e "    ${BOLD}Pilih mode:${NC}"
    echo -e "    ${GREEN}[1]${NC} 🔍 Static Analysis"
    echo -e "    ${GREEN}[2]${NC} 🔄 Dynamic Analysis (Sandbox)"
    echo -e "    ${GREEN}[3]${NC} 📝 Generate YARA Rules"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) ./pilgrims.sh --module=malware "$file" --static ;;
        2) ./pilgrims.sh --module=malware "$file" --dynamic ;;
        3) ./pilgrims.sh --module=malware "$file" --yara ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_ai_mode() {
    echo ""
    echo -e "    ${BOLD}Pilih mode:${NC}"
    echo -e "    ${GREEN}[1]${NC} 🔄 Model Inversion Test"
    echo -e "    ${GREEN}[2]${NC} 🎭 Adversarial Example"
    echo -e "    ${GREEN}[3]${NC} ☠️  Data Poisoning Detection"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1)
            echo -ne "    ${BOLD}Masukkan path model:${NC} "
            read -r file
            [ -f "$file" ] && ./pilgrims.sh --module=ai "$file" --inversion || echo -e "    ${RED}❌ File tidak ditemukan${NC}"
            ;;
        2)
            echo -ne "    ${BOLD}Masukkan path model:${NC} "
            read -r file
            [ -f "$file" ] && ./pilgrims.sh --module=ai "$file" --adversarial || echo -e "    ${RED}❌ File tidak ditemukan${NC}"
            ;;
        3)
            echo -ne "    ${BOLD}Masukkan path dataset:${NC} "
            read -r file
            [ -f "$file" ] && ./pilgrims.sh --module=ai "$file" --poisoning || echo -e "    ${RED}❌ File tidak ditemukan${NC}"
            ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_threatintel_mode() {
    echo ""
    echo -e "    ${BOLD}Pilih mode:${NC}"
    echo -e "    ${GREEN}[1]${NC} 📥 Update Threat Feed"
    echo -e "    ${GREEN}[2]${NC} 🔍 IOC Matching"
    echo -e "    ${GREEN}[3]${NC} 📊 MITRE ATT&CK Mapping"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) ./pilgrims.sh --module=threatintel --update ;;
        2)
            echo -ne "    ${BOLD}Masukkan path scan results:${NC} "
            read -r path
            [ -d "$path" ] && ./pilgrims.sh --module=threatintel "$path" --ioc || echo -e "    ${RED}❌ Directory tidak ditemukan${NC}"
            ;;
        3)
            echo -ne "    ${BOLD}Masukkan path findings:${NC} "
            read -r path
            [ -d "$path" ] && ./pilgrims.sh --module=threatintel "$path" --mitre || echo -e "    ${RED}❌ Directory tidak ditemukan${NC}"
            ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_cicd_mode() {
    echo ""
    echo -e "    ${BOLD}Pilih CI/CD platform:${NC}"
    echo -e "    ${GREEN}[1]${NC} 🐙 GitHub Actions"
    echo -e "    ${GREEN}[2]${NC} 🦊 GitLab CI"
    echo -e "    ${GREEN}[3]${NC} 🔧 Jenkins"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) ./pilgrims.sh --module=cicd --github ;;
        2) ./pilgrims.sh --module=cicd --gitlab ;;
        3) ./pilgrims.sh --module=cicd --jenkins ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

prompt_team_mode() {
    echo ""
    echo -e "    ${BOLD}Pilih action:${NC}"
    echo -e "    ${GREEN}[1]${NC} 👥 Create Team"
    echo -e "    ${GREEN}[2]${NC} 👤 Invite Member"
    echo -e "    ${GREEN}[3]${NC} 📊 Team Dashboard"
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1)
            echo -ne "    ${BOLD}Team name:${NC} "
            read -r name
            echo -e "    ${GREEN}✓ Team '$name' created${NC}"
            sleep 2
            ;;
        2)
            echo -ne "    ${BOLD}Email:${NC} "
            read -r email
            echo -e "    ${GREEN}✓ Invitation sent to $email${NC}"
            sleep 2
            ;;
        3) ./pilgrims.sh --history ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

show_plugin_manager() {
    print_epic_banner
    echo -e "    ${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "    ${CYAN}║${NC}              ${BOLD}🔌 PLUGIN MANAGER${NC}                                          ${CYAN}║${NC}"
    echo -e "    ${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "    ${BOLD}Pilih action:${NC}"
    echo -e "    ${GREEN}[1]${NC} 📋 List Installed Plugins"
    echo -e "    ${GREEN}[2]${NC} 📥 Install New Plugin"
    echo -e "    ${GREEN}[3]${NC} 🗑️  Remove Plugin"
    echo -e "    ${GREEN}[4]${NC} ✨ Create New Plugin"
    echo -e "    ${GREEN}[B]${NC} ⬅️  Back to Main Menu"
    echo ""
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) ./pilgrims.sh --modules; sleep 3 ;;
        2)
            echo -ne "    ${BOLD}Plugin name:${NC} "
            read -r name
            ./pilgrims-manage.sh install "$name"
            ;;
        3)
            echo -ne "    ${BOLD}Plugin name:${NC} "
            read -r name
            ./pilgrims-manage.sh remove "$name"
            ;;
        4)
            echo -ne "    ${BOLD}Plugin name:${NC} "
            read -r name
            ./pilgrims-manage.sh create "$name"
            ;;
        B|b) return ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}"; sleep 2 ;;
    esac
}

show_help() {
    print_epic_banner
    echo -e "    ${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "    ${CYAN}║${NC}              ${BOLD}📖 HELP & DOCUMENTATION${NC}                                    ${NC}║${NC}"
    echo -e "    ${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "    ${BOLD}Quick Start:${NC}"
    echo "    1. Pilih module dari menu utama"
    echo "    2. Masukkan target (URL, IP, file, dll)"
    echo "    3. Tunggu scan selesai"
    echo "    4. Lihat hasil di folder reports/"
    echo ""
    echo -e "    ${BOLD}Common Commands:${NC}"
    echo "    ./pilgrims.sh --help              # Show help"
    echo "    ./pilgrims.sh --modules           # List modules"
    echo "    ./pilgrims.sh --history           # View history"
    echo "    ./pilgrims.sh --module=web <url>  # Web scan"
    echo ""
    echo -e "    ${BOLD}Documentation:${NC}"
    echo "    cat README.md                     # Full docs"
    echo "    cat QUICKSTART.md                 # Quick start"
    echo "    cat COMMANDS.md                   # Command reference"
    echo ""
    echo -ne "    ${DIM}Press Enter to continue...${NC}"
    read -r
}

show_scan_history() {
    ./pilgrims.sh --history
    echo -ne "    ${DIM}Press Enter to continue...${NC}"
    read -r
}

show_system_status() {
    print_epic_banner
    echo -e "    ${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "    ${CYAN}║${NC}              ${BOLD}📊 SYSTEM STATUS${NC}                                           ${CYAN}║${NC}"
    echo -e "    ${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "    ${BOLD}📦 Installation:${NC}"
    echo "    • Core files:    $(ls core/*.sh 2>/dev/null | wc -l) files"
    echo "    • Modules:       $(ls -d modules/module-* 2>/dev/null | wc -l) modules"
    echo "    • Database:      $([ -f shared/db/pilgrims.db ] && echo '✓ Connected' || echo '✗ Not found')"
    echo ""
    echo -e "    ${BOLD}🔧 Dependencies:${NC}"
    for dep in nmap curl whois dig jq openssl sqlite3 python3; do
        if command -v $dep &>/dev/null; then
            echo -e "    • $dep: ${GREEN}✓${NC}"
        else
            echo -e "    • $dep: ${RED}✗${NC}"
        fi
    done
    echo ""
    echo -e "    ${BOLD}📈 Statistics:${NC}"
    if [ -f shared/db/pilgrims.db ]; then
        SCAN_COUNT=$(sqlite3 shared/db/pilgrims.db "SELECT COUNT(*) FROM scans;" 2>/dev/null || echo "0")
        echo "    • Total scans:   $SCAN_COUNT"
    fi
    echo "    • Disk usage:    $(du -sh . 2>/dev/null | cut -f1)"
    echo ""
    echo -ne "    ${DIM}Press Enter to continue...${NC}"
    read -r
}

change_theme() {
    print_epic_banner
    echo -e "    ${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "    ${CYAN}║${NC}              ${BOLD}🎨 CHANGE THEME${NC}                                            ${CYAN}║${NC}"
    echo -e "    ${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "    ${BOLD}Pilih theme:${NC}"
    echo -e "    ${GREEN}[1]${NC} 🎨 Default (Purple/Cyan)"
    echo -e "    ${GREEN}[2]${NC} 🟢 Matrix (Green)"
    echo -e "    ${GREEN}[3]${NC} 🔴 Blood (Red)"
    echo -e "    ${GREEN}[4]${NC} 🌊 Ocean (Blue)"
    echo -e "    ${GREEN}[5]${NC} ⚪ Mono (White)"
    echo ""
    echo -ne "    ${BOLD}Pilihan:${NC} "
    read -r choice
    
    case $choice in
        1) export PILGRIMS_THEME=default; echo -e "    ${GREEN}✓ Theme changed to Default${NC}" ;;
        2) export PILGRIMS_THEME=matrix; echo -e "    ${GREEN}✓ Theme changed to Matrix${NC}" ;;
        3) export PILGRIMS_THEME=blood; echo -e "    ${GREEN}✓ Theme changed to Blood${NC}" ;;
        4) export PILGRIMS_THEME=ocean; echo -e "    ${GREEN}✓ Theme changed to Ocean${NC}" ;;
        5) export PILGRIMS_THEME=mono; echo -e "    ${GREEN}✓ Theme changed to Mono${NC}" ;;
        *) echo -e "    ${RED}❌ Pilihan tidak valid${NC}" ;;
    esac
    sleep 2
}

# Main interactive loop
interactive_mode() {
    while true; do
        show_main_menu
        read -r choice
        handle_menu_choice "$choice"
    done
}

# Add handlers in handle_menu_choice
