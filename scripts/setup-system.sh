#!/bin/bash

set -euo pipefail  # Sair em erros, variáveis não definidas, e falhas em pipes

# Cores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Funções de logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[PASSO]${NC} $1"
}

# Função para pedir confirmação
confirm() {
    local prompt="$1"
    local default="${2:-n}"  # Default é 'n' se não especificado
    
    if [ "$default" = "y" ]; then
        prompt="$prompt (S/n): "
    else
        prompt="$prompt (s/N): "
    fi
    
    read -p "$(echo -e ${YELLOW}${prompt}${NC})" -n 1 -r
    echo
    
    if [ "$default" = "y" ]; then
        [[ $REPLY =~ ^[Nn]$ ]] && return 1 || return 0
    else
        [[ $REPLY =~ ^[SsYy]$ ]] && return 0 || return 1
    fi
}

# Detectar sistema operacional
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Detectar package manager
detect_package_manager() {
    if command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    else
        echo "unknown"
    fi
}

# Atualizar sistema
update_system() {
    local pkg_manager="$1"
    
    log_step "Atualização do sistema"
    
    case "$pkg_manager" in
        dnf)
            log_info "Sistema baseado em Fedora/RHEL detectado"
            
            log_info "Verificando atualizações disponíveis..."
            echo ""
            sudo dnf check-update || true  # check-update retorna 100 se há updates
            echo ""
            
            if confirm "Deseja instalar as atualizações mostradas acima? (dnf upgrade)"; then
                log_info "Instalando atualizações..."
                sudo dnf upgrade -y
                log_info "Sistema atualizado com sucesso!"
            else
                log_warn "Atualização cancelada pelo usuário"
            fi
            ;;
            
        apt)
            log_info "Sistema baseado em Debian/Ubuntu detectado"
            
            log_info "Atualizando lista de pacotes..."
            sudo apt update
            echo ""
            
            log_info "Atualizações disponíveis:"
            apt list --upgradable 2>/dev/null | grep -v "Listing"
            echo ""
            
            if confirm "Deseja instalar as atualizações mostradas acima? (apt upgrade)"; then
                log_info "Instalando atualizações..."
                sudo apt upgrade -y
                log_info "Sistema atualizado com sucesso!"
            else
                log_warn "Atualização cancelada pelo usuário"
            fi
            ;;
            
        yum)
            log_info "Sistema baseado em CentOS/RHEL antigo detectado"
            
            log_info "Verificando atualizações disponíveis..."
            echo ""
            sudo yum check-update || true
            echo ""
            
            if confirm "Deseja instalar as atualizações mostradas acima? (yum update)"; then
                log_info "Instalando atualizações..."
                sudo yum update -y
                log_info "Sistema atualizado com sucesso!"
            else
                log_warn "Atualização cancelada pelo usuário"
            fi
            ;;
    esac
}

# Instalar Homebrew
install_homebrew() {
    log_step "Instalação do Homebrew"
    
    if command -v brew &> /dev/null; then
        log_info "Homebrew já está instalado!"
        log_info "Versão: $(brew --version | head -n1)"
        
        if confirm "Deseja atualizar o Homebrew?"; then
            log_info "Atualizando Homebrew..."
            brew update
            brew upgrade
            log_info "Homebrew atualizado!"
        fi
        return 0
    fi
    
    if ! confirm "Deseja instalar o Homebrew?"; then
        log_warn "Instalação do Homebrew cancelada"
        return 1
    fi
    
    log_info "Instalando dependências do Homebrew..."
    local pkg_manager="$1"
    
    case "$pkg_manager" in
        dnf)
            sudo dnf groupinstall -y 'Development Tools'
            sudo dnf install -y procps-ng curl file git
            ;;
        apt)
            sudo apt install -y build-essential procps curl file git
            ;;
        yum)
            sudo yum groupinstall -y 'Development Tools'
            sudo yum install -y procps-ng curl file git
            ;;
    esac
    
    log_info "Baixando e instalando Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configurar PATH do Homebrew
    log_info "Configurando PATH do Homebrew..."
    
    local brew_path=""
    if [ -d "/home/linuxbrew/.linuxbrew" ]; then
        brew_path="/home/linuxbrew/.linuxbrew"
    elif [ -d "$HOME/.linuxbrew" ]; then
        brew_path="$HOME/.linuxbrew"
    fi
    
    if [ -n "$brew_path" ]; then
        # Adicionar ao .bashrc
        if [ -f "$HOME/.bashrc" ]; then
            if ! grep -q "linuxbrew" "$HOME/.bashrc"; then
                echo '' >> "$HOME/.bashrc"
                echo '# Homebrew' >> "$HOME/.bashrc"
                echo "eval \"\$($brew_path/bin/brew shellenv)\"" >> "$HOME/.bashrc"
            fi
        fi
        
        # Adicionar ao .zshrc se existir
        if [ -f "$HOME/.zshrc" ]; then
            if ! grep -q "linuxbrew" "$HOME/.zshrc"; then
                echo '' >> "$HOME/.zshrc"
                echo '# Homebrew' >> "$HOME/.zshrc"
                echo "eval \"\$($brew_path/bin/brew shellenv)\"" >> "$HOME/.zshrc"
            fi
        fi
        
        # Carregar para sessão atual
        eval "$($brew_path/bin/brew shellenv)"
        
        log_info "Homebrew instalado com sucesso!"
        log_info "Versão: $(brew --version | head -n1)"
    else
        log_error "Não foi possível encontrar instalação do Homebrew"
        return 1
    fi
}

# Instalar ferramentas Kubernetes
install_k8s_tools() {
    log_step "Instalação de ferramentas Kubernetes"
    
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew não está disponível. Instale-o primeiro."
        return 1
    fi
    
    # Lista de ferramentas com descrições
    declare -A tools_desc=(
        ["kubectx"]="Trocar facilmente entre clusters e namespaces"
        ["k9s"]="Interface TUI para gerenciar clusters Kubernetes"
        ["popeye"]="Scanner de configurações de cluster Kubernetes"
        ["stern"]="Tail de logs de múltiplos pods simultaneamente"
        ["helm"]="Package manager para Kubernetes"
        ["kubectl"]="CLI oficial do Kubernetes"
    )
    
    echo ""
    log_info "Ferramentas Kubernetes disponíveis:"
    echo ""
    
    local idx=1
    declare -a tools_list=()
    for tool in kubectx k9s popeye stern helm kubectl; do
        tools_list+=("$tool")
        if command -v "$tool" &> /dev/null; then
            echo -e "  ${idx}. ${GREEN}✓${NC} ${YELLOW}$tool${NC} - ${tools_desc[$tool]} ${GREEN}(já instalado)${NC}"
        else
            echo -e "  ${idx}. ${RED}✗${NC} ${YELLOW}$tool${NC} - ${tools_desc[$tool]}"
        fi
        ((idx++))
    done
    echo ""
    
    if ! confirm "Deseja instalar ferramentas Kubernetes?"; then
        log_warn "Instalação de ferramentas cancelada"
        return 0
    fi
    
    echo ""
    log_info "Você poderá escolher cada ferramenta individualmente"
    echo ""
    
    # Instalar kubectx (inclui kubens)
    if ! command -v kubectx &> /dev/null; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}kubectx + kubens${NC}"
        echo "  Permite trocar rapidamente entre:"
        echo "    • Clusters Kubernetes (kubectx)"
        echo "    • Namespaces (kubens)"
        echo "  Exemplo: kubectx production"
        echo "           kubens kube-system"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if confirm "Instalar kubectx + kubens?"; then
            log_info "Instalando kubectx..."
            brew install kubectx
            log_info "✓ kubectx + kubens instalados!"
        else
            log_warn "kubectx: instalação pulada"
        fi
        echo ""
    else
        log_info "kubectx já está instalado (pulando)"
    fi
    
    # Instalar k9s
    if ! command -v k9s &> /dev/null; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}k9s${NC}"
        echo "  Interface TUI (Terminal UI) completa para Kubernetes"
        echo "    • Visualizar pods, deployments, services"
        echo "    • Ver logs em tempo real"
        echo "    • Fazer port-forward, delete, scale"
        echo "    • Atalhos de teclado tipo Vim"
        echo "  Uso: apenas digite 'k9s' no terminal"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if confirm "Instalar k9s?"; then
            log_info "Instalando k9s..."
            brew install derailed/k9s/k9s
            log_info "✓ k9s instalado!"
        else
            log_warn "k9s: instalação pulada"
        fi
        echo ""
    else
        log_info "k9s já está instalado (pulando)"
    fi
    
    # Instalar popeye
    if ! command -v popeye &> /dev/null; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}popeye${NC}"
        echo "  Escaneia seu cluster e sugere melhorias"
        echo "    • Detecta recursos não utilizados"
        echo "    • Identifica problemas de configuração"
        echo "    • Sugere boas práticas"
        echo "    • Gera relatórios coloridos"
        echo "  Uso: popeye"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if confirm "Instalar popeye?"; then
            log_info "Instalando popeye..."
            brew install derailed/popeye/popeye
            log_info "✓ popeye instalado!"
        else
            log_warn "popeye: instalação pulada"
        fi
        echo ""
    else
        log_info "popeye já está instalado (pulando)"
    fi
    
    # Instalar stern (útil para logs)
    if ! command -v stern &> /dev/null; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}stern${NC}"
        echo "  Tail de logs de múltiplos pods simultaneamente"
        echo "    • Ver logs de todos os pods de um deployment"
        echo "    • Filtrar por regex"
        echo "    • Colorização automática por pod"
        echo "  Exemplo: stern myapp --namespace production"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if confirm "Instalar stern?"; then
            log_info "Instalando stern..."
            brew install stern
            log_info "✓ stern instalado!"
        else
            log_warn "stern: instalação pulada"
        fi
        echo ""
    else
        log_info "stern já está instalado (pulando)"
    fi
    
    # Instalar helm
    if ! command -v helm &> /dev/null; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}helm${NC}"
        echo "  Package manager para Kubernetes"
        echo "    • Instalar aplicações complexas com um comando"
        echo "    • Gerenciar releases e rollbacks"
        echo "    • Templates de manifests"
        echo "  Exemplo: helm install prometheus prometheus-community/prometheus"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if confirm "Instalar helm?"; then
            log_info "Instalando helm..."
            brew install helm
            log_info "✓ helm instalado!"
        else
            log_warn "helm: instalação pulada"
        fi
        echo ""
    else
        log_info "helm já está instalado (pulando)"
    fi
    
    # Instalar kubectl (se ainda não tiver)
    if ! command -v kubectl &> /dev/null; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}kubectl${NC}"
        echo "  CLI oficial do Kubernetes (essencial)"
        echo "    • Gerenciar todos os recursos do cluster"
        echo "    • Criar, atualizar, deletar recursos"
        echo "    • Ver logs, fazer port-forward, exec"
        echo "  Exemplo: kubectl get pods -A"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if confirm "Instalar kubectl?"; then
            log_info "Instalando kubectl..."
            brew install kubectl
            log_info "✓ kubectl instalado!"
        else
            log_warn "kubectl: instalação pulada"
        fi
        echo ""
    else
        log_info "kubectl já está instalado (pulando)"
    fi
}

# Mostrar resumo final
show_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    log_info "RESUMO DA INSTALAÇÃO"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Verificar Homebrew
    if command -v brew &> /dev/null; then
        echo -e "${GREEN}✓${NC} Homebrew: $(brew --version | head -n1)"
    else
        echo -e "${RED}✗${NC} Homebrew: não instalado"
    fi
    
    # Verificar ferramentas K8s
    local tools=("kubectx" "kubens" "k9s" "popeye" "stern" "helm" "kubectl")
    
    echo ""
    echo "Ferramentas Kubernetes:"
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            local version=$(eval "$tool version --short 2>/dev/null || $tool version 2>/dev/null || echo 'instalado'" | head -n1)
            echo -e "  ${GREEN}✓${NC} $tool: $version"
        else
            echo -e "  ${RED}✗${NC} $tool: não instalado"
        fi
    done
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    log_info "Para usar as ferramentas instaladas, execute:"
    echo -e "  ${YELLOW}source ~/.bashrc${NC}  (ou ${YELLOW}source ~/.zshrc${NC} se usar zsh)"
    echo ""
    log_info "Ou abra um novo terminal"
    echo ""
}

# Main
main() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${BLUE}   Script de Setup - Sistema + Kubernetes Tools${NC}"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Detectar sistema
    local os=$(detect_os)
    local pkg_manager=$(detect_package_manager)
    
    log_info "Sistema operacional: $os"
    log_info "Package manager: $pkg_manager"
    echo ""
    
    # Verificar se é suportado
    if [ "$pkg_manager" = "unknown" ]; then
        log_error "Sistema operacional não suportado!"
        log_error "Este script suporta apenas sistemas com dnf, apt ou yum"
        exit 1
    fi
    
    log_info "Sistema suportado! ✓"
    echo ""
    
    # Menu de opções
    echo "Este script irá:"
    echo "  1. Atualizar o sistema ($pkg_manager)"
    echo "  2. Instalar Homebrew (se necessário)"
    echo "  3. Instalar ferramentas Kubernetes (kubectx, k9s, popeye, etc)"
    echo ""
    
    if ! confirm "Deseja continuar?"; then
        log_warn "Script cancelado pelo usuário"
        exit 0
    fi
    
    echo ""
    
    # Executar passos
    update_system "$pkg_manager"
    echo ""
    
    install_homebrew "$pkg_manager"
    echo ""
    
    install_k8s_tools
    echo ""
    
    show_summary
    
    log_info "Script concluído com sucesso!"
    echo ""
}

# Executar main
main "$@"
