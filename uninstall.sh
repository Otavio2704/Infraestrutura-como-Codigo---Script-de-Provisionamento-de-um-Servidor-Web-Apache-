#!/bin/bash

#============================================================
# SCRIPT DE DESINSTALAÇÃO DO SERVIDOR WEB
# Uso: sudo web-uninstall.sh  ou  sudo ./uninstall.sh
#============================================================

# ==================== CORES ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==================== VERIFICAÇÃO ====================
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[✖] Execute como root: sudo $0${NC}"
    exit 1
fi

# ==================== BANNER ====================
echo -e "${YELLOW}"
echo "╔══════════════════════════════════════════════════╗"
echo "║                                                ║"
echo "║   ⚠️  DESINSTALAÇÃO DO SERVIDOR WEB             ║"
echo "║                                                ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ==================== CONFIRMAÇÃO ====================
echo -e "${RED}Esta ação irá remover:${NC}"
echo -e "  • Apache2 e suas configurações"
echo -e "  • Arquivos do site em /var/www/html"
echo -e "  • Scripts de monitoramento"
echo -e "  • Logs de provisionamento"
echo ""

read -p "Tem certeza que deseja continuar? (s/N): " CONFIRM

if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ]; then
    echo -e "${GREEN}[✔] Operação cancelada.${NC}"
    exit 0
fi

echo ""

# ==================== ETAPA 1: PARAR APACHE ====================
echo -e "${YELLOW}[1/6] Parando Apache2...${NC}"

if systemctl is-active --quiet apache2; then
    systemctl stop apache2 2>/dev/null
    systemctl disable apache2 2>/dev/null
    echo -e "${GREEN}  [✔] Apache2 parado e desabilitado${NC}"
else
    echo -e "${CYAN}  [ℹ] Apache2 já estava parado${NC}"
fi

# ==================== ETAPA 2: REMOVER APACHE ====================
echo -e "${YELLOW}[2/6] Removendo Apache2...${NC}"

apt-get purge apache2 apache2-utils apache2-bin -y > /dev/null 2>&1
apt-get autoremove -y > /dev/null 2>&1
apt-get autoclean -y > /dev/null 2>&1

echo -e "${GREEN}  [✔] Apache2 removido${NC}"

# ==================== ETAPA 3: REMOVER CONFIGURAÇÕES ====================
echo -e "${YELLOW}[3/6] Removendo configurações...${NC}"

rm -rf /etc/apache2
echo -e "${GREEN}  [✔] /etc/apache2 removido${NC}"

# ==================== ETAPA 4: REMOVER ARQUIVOS WEB ====================
echo -e "${YELLOW}[4/6] Removendo arquivos do site...${NC}"

# Perguntar se deseja manter backup
if [ -f /var/www/html/index.html ]; then
    read -p "  Deseja fazer backup da página antes de remover? (s/N): " BACKUP

    if [ "$BACKUP" == "s" ] || [ "$BACKUP" == "S" ]; then
        BACKUP_DIR="$HOME/backup-web-$(date '+%Y%m%d-%H%M%S')"
        mkdir -p "$BACKUP_DIR"
        cp -r /var/www/html/* "$BACKUP_DIR/" 2>/dev/null
        echo -e "${GREEN}  [✔] Backup salvo em: $BACKUP_DIR${NC}"
    fi
fi

rm -rf /var/www/html
echo -e "${GREEN}  [✔] /var/www/html removido${NC}"

# ==================== ETAPA 5: REMOVER SCRIPTS ====================
echo -e "${YELLOW}[5/6] Removendo scripts auxiliares...${NC}"

rm -f /usr/local/bin/web-monitor.sh
echo -e "${GREEN}  [✔] web-monitor.sh removido${NC}"

# ==================== ETAPA 6: LIMPAR LOGS ====================
echo -e "${YELLOW}[6/6] Limpando logs...${NC}"

rm -f /var/log/provisioning.log
rm -rf /var/log/apache2
echo -e "${GREEN}  [✔] Logs removidos${NC}"

# ==================== FIREWALL ====================
echo ""
read -p "Deseja resetar as regras do Firewall (UFW)? (s/N): " RESET_UFW

if [ "$RESET_UFW" == "s" ] || [ "$RESET_UFW" == "S" ]; then
    ufw delete allow 80/tcp > /dev/null 2>&1
    ufw delete allow 443/tcp > /dev/null 2>&1
    ufw delete allow 'Apache Full' > /dev/null 2>&1
    echo -e "${GREEN}  [✔] Regras do Apache removidas do UFW${NC}"
fi

# ==================== RELATÓRIO FINAL ====================
echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════╗"
echo "║                                                ║"
echo "║   ✅ SERVIDOR WEB REMOVIDO COM SUCESSO!        ║"
echo "║                                                ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║                                                ║"
echo "║   Itens removidos:                             ║"
echo "║   • Apache2 + dependências                    ║"
echo "║   • Configurações (/etc/apache2)               ║"
echo "║   • Arquivos web (/var/www/html)               ║"
echo "║   • Scripts auxiliares                         ║"
echo "║   • Logs de provisionamento                   ║"
echo "║                                                ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# Auto-remover o script instalado
rm -f /usr/local/bin/web-uninstall.sh
