#!/bin/bash

#============================================================
# SCRIPT DE MONITORAMENTO DO SERVIDOR WEB
# Uso: sudo web-monitor.sh  ou  sudo ./monitor.sh
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
clear
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════╗"
echo "║     📊 MONITORAMENTO DO SERVIDOR WEB            ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ==================== STATUS DO APACHE ====================
echo -e "${CYAN}━━━ Status do Apache2 ━━━${NC}"

if systemctl is-active --quiet apache2; then
    echo -e "  Status: ${GREEN}● Ativo (rodando)${NC}"
else
    echo -e "  Status: ${RED}● Inativo (parado)${NC}"
fi

APACHE_PID=$(pidof apache2 | awk '{print $1}')
echo -e "  PID Principal: ${YELLOW}${APACHE_PID:-N/A}${NC}"
echo -e "  Processos Apache: ${YELLOW}$(pgrep -c apache2 2>/dev/null || echo 0)${NC}"
echo ""

# ==================== SISTEMA ====================
echo -e "${CYAN}━━━ Sistema ━━━${NC}"
echo -e "  Hostname: ${YELLOW}$(hostname)${NC}"
echo -e "  IP: ${YELLOW}$(hostname -I | awk '{print $1}')${NC}"
echo -e "  Uptime: ${YELLOW}$(uptime -p)${NC}"
echo -e "  Carga: ${YELLOW}$(cat /proc/loadavg | awk '{print $1, $2, $3}')${NC}"
echo ""

# ==================== RECURSOS ====================
echo -e "${CYAN}━━━ Recursos ━━━${NC}"

# CPU
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo -e "  CPU: ${YELLOW}${CPU_USAGE}%${NC}"

# Memória
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))

if [ $MEM_PERCENT -gt 80 ]; then
    MEM_COLOR=$RED
elif [ $MEM_PERCENT -gt 60 ]; then
    MEM_COLOR=$YELLOW
else
    MEM_COLOR=$GREEN
fi

echo -e "  Memória: ${MEM_COLOR}${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_PERCENT}%)${NC}"

# Disco
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
DISK_AVAIL=$(df -h / | awk 'NR==2 {print $4}')
echo -e "  Disco: ${YELLOW}Usado: $DISK_USAGE | Livre: $DISK_AVAIL${NC}"
echo ""

# ==================== PORTAS ====================
echo -e "${CYAN}━━━ Portas Ativas ━━━${NC}"

for PORT in 22 80 443; do
    if ss -tlnp | grep -q ":$PORT "; then
        echo -e "  Porta ${GREEN}$PORT${NC}: ● Aberta"
    else
        echo -e "  Porta ${RED}$PORT${NC}: ○ Fechada"
    fi
done
echo ""

# ==================== ÚLTIMOS ACESSOS ====================
echo -e "${CYAN}━━━ Últimos 5 Acessos ━━━${NC}"

if [ -f /var/log/apache2/access.log ] && [ -s /var/log/apache2/access.log ]; then
    tail -5 /var/log/apache2/access.log | while read line; do
        IP=$(echo "$line" | awk '{print $1}')
        REQUEST=$(echo "$line" | awk -F'"' '{print $2}')
        STATUS=$(echo "$line" | awk '{print $9}')

        if [ "$STATUS" == "200" ]; then
            STATUS_COLOR=$GREEN
        elif [ "$STATUS" -ge 400 ] 2>/dev/null; then
            STATUS_COLOR=$RED
        else
            STATUS_COLOR=$YELLOW
        fi

        echo -e "  ${YELLOW}$IP${NC} | $REQUEST | ${STATUS_COLOR}Status: $STATUS${NC}"
    done
else
    echo -e "  ${YELLOW}Nenhum log de acesso encontrado${NC}"
fi
echo ""

# ==================== ERROS RECENTES ====================
echo -e "${CYAN}━━━ Últimos 3 Erros ━━━${NC}"

if [ -f /var/log/apache2/error.log ] && [ -s /var/log/apache2/error.log ]; then
    tail -3 /var/log/apache2/error.log | while read line; do
        echo -e "  ${RED}$line${NC}"
    done
else
    echo -e "  ${GREEN}Nenhum erro encontrado ✔${NC}"
fi
echo ""

# ==================== FIREWALL ====================
echo -e "${CYAN}━━━ Firewall (UFW) ━━━${NC}"

if command -v ufw &> /dev/null; then
    UFW_STATUS=$(ufw status | head -1)
    echo -e "  $UFW_STATUS"
    ufw status | grep -E "ALLOW|DENY" | while read line; do
        echo -e "  ${YELLOW}$line${NC}"
    done
else
    echo -e "  ${RED}UFW não instalado${NC}"
fi

echo ""

# ==================== TESTE DE RESPOSTA ====================
echo -e "${CYAN}━━━ Teste de Resposta ━━━${NC}"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null)
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" http://localhost 2>/dev/null)

if [ "$HTTP_CODE" == "200" ]; then
    echo -e "  HTTP Status: ${GREEN}$HTTP_CODE OK${NC}"
else
    echo -e "  HTTP Status: ${RED}$HTTP_CODE${NC}"
fi

echo -e "  Tempo de resposta: ${YELLOW}${RESPONSE_TIME}s${NC}"
echo ""

# ==================== RODAPÉ ====================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Relatório gerado em: $(date '+%d/%m/%Y %H:%M:%S')"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
