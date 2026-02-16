#!/bin/bash

#============================================================
# SCRIPT DE PROVISIONAMENTO AUTOMÁTICO DE SERVIDOR WEB
# Descrição: Provisiona um servidor web Apache2 completo
#            com configurações de segurança e monitoramento
#============================================================

# ==================== VARIÁVEIS ====================
LOG_FILE="/var/log/provisioning.log"
WEB_DIR="/var/www/html"
APACHE_CONF="/etc/apache2"
SERVER_NAME="meu-servidor-web"
ADMIN_EMAIL="admin@exemplo.com"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ==================== CORES ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==================== FUNÇÕES UTILITÁRIAS ====================

log() {
    local LEVEL=$1
    local MESSAGE=$2
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] [$LEVEL] $MESSAGE" >> "$LOG_FILE"

    case $LEVEL in
        "INFO")  echo -e "${GREEN}[✔] $MESSAGE${NC}" ;;
        "WARN")  echo -e "${YELLOW}[⚠] $MESSAGE${NC}" ;;
        "ERROR") echo -e "${RED}[✖] $MESSAGE${NC}" ;;
        "STEP")  echo -e "${CYAN}[➤] $MESSAGE${NC}" ;;
    esac
}

show_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                        ║"
    echo "║   🌐 PROVISIONAMENTO AUTOMÁTICO DE SERVIDOR WEB 🌐    ║"
    echo "║                                                        ║"
    echo "║   Apache2 + Segurança + Monitoramento                  ║"
    echo "║                                                        ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ==================== VERIFICAÇÕES ====================

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log "ERROR" "Este script precisa ser executado como root (sudo)"
        echo -e "${RED}Use: sudo bash $0${NC}"
        exit 1
    fi
    log "INFO" "Verificação de privilégios: OK (root)"
}

check_os() {
    log "STEP" "Verificando sistema operacional..."

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        log "INFO" "Sistema detectado: $NAME $VERSION_ID"
    else
        log "ERROR" "Sistema operacional não suportado"
        exit 1
    fi

    if ! command -v apt &> /dev/null; then
        log "ERROR" "Este script suporta apenas sistemas baseados em Debian/Ubuntu"
        exit 1
    fi
}

check_network() {
    log "STEP" "Verificando conectividade de rede..."

    if ping -c 1 google.com &> /dev/null; then
        log "INFO" "Conectividade de rede: OK"
    else
        log "ERROR" "Sem conexão com a internet"
        exit 1
    fi
}

# ==================== INSTALAÇÃO ====================

update_system() {
    log "STEP" "Atualizando repositórios e pacotes..."

    apt-get update -y >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        log "INFO" "Repositórios atualizados com sucesso"
    else
        log "ERROR" "Falha ao atualizar repositórios"
        exit 1
    fi

    apt-get upgrade -y >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        log "INFO" "Pacotes atualizados com sucesso"
    else
        log "WARN" "Alguns pacotes podem não ter sido atualizados"
    fi
}

install_apache() {
    log "STEP" "Instalando Apache2..."

    if dpkg -l | grep -q apache2; then
        log "WARN" "Apache2 já está instalado. Reconfigurando..."
    else
        apt-get install apache2 -y >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            log "INFO" "Apache2 instalado com sucesso"
        else
            log "ERROR" "Falha na instalação do Apache2"
            exit 1
        fi
    fi
}

install_dependencies() {
    log "STEP" "Instalando pacotes adicionais..."

    local PACKAGES=("unzip" "curl" "wget" "ufw" "net-tools" "htop" "tree")

    for package in "${PACKAGES[@]}"; do
        if dpkg -l | grep -q "$package"; then
            log "INFO" "Pacote '$package' já instalado"
        else
            apt-get install "$package" -y >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                log "INFO" "Pacote '$package' instalado"
            else
                log "WARN" "Falha ao instalar '$package'"
            fi
        fi
    done
}

# ==================== CONFIGURAÇÃO ====================

configure_firewall() {
    log "STEP" "Configurando Firewall (UFW)..."

    ufw --force enable >> "$LOG_FILE" 2>&1
    ufw allow 22/tcp >> "$LOG_FILE" 2>&1
    ufw allow 80/tcp >> "$LOG_FILE" 2>&1
    ufw allow 443/tcp >> "$LOG_FILE" 2>&1
    ufw allow 'Apache Full' >> "$LOG_FILE" 2>&1

    log "INFO" "Firewall configurado (portas 22, 80, 443)"
}

configure_apache() {
    log "STEP" "Configurando Apache2..."

    # Habilitar módulos
    a2enmod rewrite >> "$LOG_FILE" 2>&1
    a2enmod headers >> "$LOG_FILE" 2>&1
    a2enmod ssl >> "$LOG_FILE" 2>&1
    log "INFO" "Módulos habilitados (rewrite, headers, ssl)"

    # ServerName
    echo "ServerName $SERVER_NAME" > "$APACHE_CONF/conf-available/servername.conf"
    a2enconf servername >> "$LOG_FILE" 2>&1
    log "INFO" "ServerName configurado: $SERVER_NAME"

    # Cabeçalhos de segurança
    cat > "$APACHE_CONF/conf-available/security-headers.conf" << 'EOF'
<IfModule mod_headers.c>
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always unset X-Powered-By
    Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
</IfModule>

ServerTokens Prod
ServerSignature Off
EOF

    a2enconf security-headers >> "$LOG_FILE" 2>&1
    log "INFO" "Cabeçalhos de segurança configurados"

    # VirtualHost
    cat > "$APACHE_CONF/sites-available/000-default.conf" << EOF
<VirtualHost *:80>
    ServerAdmin $ADMIN_EMAIL
    ServerName $SERVER_NAME
    DocumentRoot $WEB_DIR

    <Directory $WEB_DIR>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css
        AddOutputFilterByType DEFLATE application/javascript application/json
    </IfModule>
</VirtualHost>
EOF

    log "INFO" "VirtualHost configurado"
}

deploy_web_page() {
    log "STEP" "Publicando página web..."

    # Backup da original
    if [ -f "$WEB_DIR/index.html" ]; then
        mv "$WEB_DIR/index.html" "$WEB_DIR/index.html.bak"
        log "INFO" "Backup da página original criado"
    fi

    # Verificar se index.html existe no diretório do projeto
    if [ -f "$SCRIPT_DIR/index.html" ]; then

        # Substituir variáveis dinâmicas antes de copiar
        local SERVER_IP=$(hostname -I | awk '{print $1}')
        local SERVER_HOSTNAME=$(hostname)
        local PROVISION_DATE=$(date '+%d/%m/%Y às %H:%M:%S')

        sed -e "s|{{SERVER_HOSTNAME}}|$SERVER_HOSTNAME|g" \
            -e "s|{{SERVER_IP}}|$SERVER_IP|g" \
            -e "s|{{PROVISION_DATE}}|$PROVISION_DATE|g" \
            "$SCRIPT_DIR/index.html" > "$WEB_DIR/index.html"

        log "INFO" "Página copiada do projeto para $WEB_DIR"
    else
        log "ERROR" "Arquivo index.html não encontrado em $SCRIPT_DIR"
        exit 1
    fi

    # Permissões
    chown -R www-data:www-data "$WEB_DIR"
    chmod -R 755 "$WEB_DIR"

    log "INFO" "Página web publicada com sucesso"
}

create_htaccess() {
    log "STEP" "Criando .htaccess..."

    cat > "$WEB_DIR/.htaccess" << 'EOF'
RewriteEngine On
AddDefaultCharset UTF-8

<FilesMatch "^\.">
    Require all denied
</FilesMatch>

<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
    ExpiresByType image/svg+xml "access plus 1 month"
</IfModule>

ErrorDocument 404 /index.html
EOF

    log "INFO" ".htaccess configurado"
}

install_scripts() {
    log "STEP" "Instalando scripts auxiliares..."

    # Copiar monitor.sh
    if [ -f "$SCRIPT_DIR/monitor.sh" ]; then
        cp "$SCRIPT_DIR/monitor.sh" /usr/local/bin/web-monitor.sh
        chmod +x /usr/local/bin/web-monitor.sh
        log "INFO" "monitor.sh instalado em /usr/local/bin/web-monitor.sh"
    else
        log "WARN" "monitor.sh não encontrado no projeto"
    fi

    # Copiar uninstall.sh
    if [ -f "$SCRIPT_DIR/uninstall.sh" ]; then
        cp "$SCRIPT_DIR/uninstall.sh" /usr/local/bin/web-uninstall.sh
        chmod +x /usr/local/bin/web-uninstall.sh
        log "INFO" "uninstall.sh instalado em /usr/local/bin/web-uninstall.sh"
    else
        log "WARN" "uninstall.sh não encontrado no projeto"
    fi
}

start_apache() {
    log "STEP" "Iniciando Apache2..."

    apache2ctl configtest >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        log "INFO" "Configuração do Apache: Sintaxe OK"
    else
        log "ERROR" "Erro na configuração do Apache"
        exit 1
    fi

    systemctl enable apache2 >> "$LOG_FILE" 2>&1
    log "INFO" "Apache2 habilitado no boot"

    systemctl restart apache2 >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        log "INFO" "Apache2 iniciado com sucesso"
    else
        log "ERROR" "Falha ao iniciar Apache2"
        exit 1
    fi
}

# ==================== RELATÓRIO FINAL ====================

show_report() {
    local SERVER_IP=$(hostname -I | awk '{print $1}')
    local APACHE_VERSION=$(apache2 -v | head -1 | awk '{print $3}')

    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                        ║"
    echo "║   ✅ PROVISIONAMENTO CONCLUÍDO COM SUCESSO!            ║"
    echo "║                                                        ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo -e "║                                                        ║"
    echo -e "║   🌐 Acesse: ${CYAN}http://$SERVER_IP${GREEN}                       "
    echo -e "║   📦 Apache: ${YELLOW}$APACHE_VERSION${GREEN}                      "
    echo -e "║   🔒 Firewall: ${YELLOW}UFW Ativo${GREEN}                          "
    echo -e "║   📊 Monitor: ${YELLOW}sudo web-monitor.sh${GREEN}                 "
    echo -e "║   🗑️  Remover: ${YELLOW}sudo web-uninstall.sh${GREEN}               "
    echo -e "║   📋 Log: ${YELLOW}/var/log/provisioning.log${GREEN}                "
    echo "║                                                        ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ==================== EXECUÇÃO PRINCIPAL ====================

main() {
    echo "=== Início do Provisionamento: $(date) ===" > "$LOG_FILE"

    show_banner

    # Verificações
    check_root
    check_os
    check_network

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Iniciando provisionamento...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Instalação
    update_system
    install_apache
    install_dependencies

    # Configuração
    configure_firewall
    configure_apache
    deploy_web_page
    create_htaccess

    # Scripts auxiliares
    install_scripts

    # Iniciar
    start_apache

    # Relatório
    show_report

    echo "=== Provisionamento Concluído: $(date) ===" >> "$LOG_FILE"
}

main "$@"
