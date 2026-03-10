# 🌐 Provisionamento Automático de Servidor Web

<p align="center">
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/Apache-D22128?style=for-the-badge&logo=apache&logoColor=white" alt="Apache">
  <img src="https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Ubuntu">
  <img src="https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white" alt="Debian">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-concluído-brightgreen" alt="Status">
  <img src="https://img.shields.io/badge/licença-MIT-blue" alt="Licença">
  <img src="https://img.shields.io/badge/versão-1.0.0-orange" alt="Versão">
</p>

---

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Funcionalidades](#-funcionalidades)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação e Uso](#-instalação-e-uso)
- [Detalhamento dos Scripts](#-detalhamento-dos-scripts)
- [Segurança](#-segurança)
- [Demonstração](#-demonstração)
- [Solução de Problemas](#-solução-de-problemas)
- [Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [Contribuição](#-contribuição)
- [Licença](#-licença)
- [Autor](#-autor)

---

## 📖 Sobre o Projeto

Este projeto automatiza o **provisionamento completo de um servidor web** utilizando
**Shell Script** e o servidor **Apache2**. O objetivo é aplicar conceitos de
**Infraestrutura como Código (IaC)** para criar, configurar e monitorar um
servidor web de forma rápida, segura e replicável.

Um **servidor web** é um software que utiliza o protocolo HTTP para receber
requisições de clientes (navegadores) e responder com páginas web, imagens e
outros conteúdos. O **Apache2** é um dos servidores web mais utilizados no mundo,
sendo responsável por hospedar milhões de sites na internet.

### 🎯 Objetivo

Provisionar automaticamente com **um único comando**:

- ✅ Servidor web Apache2 instalado e configurado
- ✅ Firewall com regras de segurança
- ✅ Cabeçalhos HTTP de proteção
- ✅ Página web responsiva publicada
- ✅ Script de monitoramento do servidor
- ✅ Script de desinstalação limpa

---

## ⚡ Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| **Provisionamento automático** | Instala e configura tudo com um único comando |
| **Verificação inteligente** | Valida root, SO e rede antes de iniciar |
| **Instalação do Apache2** | Instala e configura o servidor web |
| **Firewall UFW** | Configura regras para portas 22, 80 e 443 |
| **Cabeçalhos de segurança** | Proteção contra XSS, Clickjacking e MIME sniffing |
| **Página web responsiva** | Deploy automático de página HTML5 + CSS3 |
| **Compressão GZIP** | Otimização de performance nas respostas |
| **Cache de arquivos** | Configuração de cache para arquivos estáticos |
| **Monitoramento** | Script completo para verificar saúde do servidor |
| **Desinstalação limpa** | Remove tudo com opção de backup |
| **Logs detalhados** | Registro de todas as operações realizadas |

---

## 📁 Estrutura do Projeto

```
web-server-provision/
│
├── provisioning.sh     # Script principal de provisionamento
├── index.html          # Página web com template de variáveis
├── monitor.sh          # Script de monitoramento do servidor
├── uninstall.sh        # Script de remoção completa
├── LICENSE             # Licença do projeto
├── .gitignore          # Quais tipos de arquivos ignorar
└── README.md           # Documentação
```

### Fluxo de Comunicação

```
provisioning.sh (ORQUESTRADOR)
│
├──► Lê index.html
│    ├── Substitui {{SERVER_HOSTNAME}}
│    ├── Substitui {{SERVER_IP}}
│    ├── Substitui {{PROVISION_DATE}}
│    └── Copia para /var/www/html/
│
├──► Lê monitor.sh
│    └── Copia para /usr/local/bin/web-monitor.sh
│
└──► Lê uninstall.sh
     └── Copia para /usr/local/bin/web-uninstall.sh
```

---

## 📌 Pré-requisitos

Antes de executar o projeto, certifique-se de ter:

- **Sistema Operacional**: Ubuntu 20.04+ / Debian 11+
- **Acesso root**: Permissões de superusuário (sudo)
- **Conexão com a internet**: Para download dos pacotes
- **Git**: Para clonar o repositório

### Verificação Rápida

```bash
# Verificar sistema operacional
cat /etc/os-release

# Verificar se tem acesso root
sudo whoami

# Verificar conexão com internet
ping -c 1 google.com

# Verificar se o Git está instalado
git --version
```

---

## 🚀 Instalação e Uso

### 1️⃣ Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/web-server-provision.git
cd web-server-provision
```

### 2️⃣ Dar Permissão de Execução

```bash
chmod +x provisioning.sh monitor.sh uninstall.sh
```

### 3️⃣ Executar o Provisionamento

```bash
sudo ./provisioning.sh
```

### 4️⃣ Acessar o Servidor

Abra o navegador e acesse:

```
http://SEU_IP_DO_SERVIDOR
```

Para descobrir o IP:

```bash
hostname -I | awk '{print $1}'
```

### 5️⃣ Monitorar o Servidor

```bash
sudo web-monitor.sh
```

### 6️⃣ Remover o Servidor (quando necessário)

```bash
sudo web-uninstall.sh
```

---

## 📜 Detalhamento dos Scripts

### `provisioning.sh` — Script Principal

Responsável por **orquestrar todo o provisionamento**. Executa as seguintes etapas:

```
 Etapa 1  → Verificação de privilégios (root)
 Etapa 2  → Verificação do sistema operacional
 Etapa 3  → Verificação de conectividade
 Etapa 4  → Atualização de repositórios e pacotes
 Etapa 5  → Instalação do Apache2
 Etapa 6  → Instalação de dependências (curl, wget, ufw...)
 Etapa 7  → Configuração do Firewall (UFW)
 Etapa 8  → Configuração do Apache (módulos, headers, vhost)
 Etapa 9  → Deploy da página web (index.html)
 Etapa 10 → Configuração do .htaccess
 Etapa 11 → Instalação dos scripts auxiliares
 Etapa 12 → Teste e inicialização do Apache
 Etapa 13 → Relatório final
```

**Pacotes instalados automaticamente:**

| Pacote | Função |
|---|---|
| `apache2` | Servidor web |
| `ufw` | Firewall |
| `curl` | Transferência de dados via URL |
| `wget` | Download de arquivos |
| `unzip` | Descompactação de arquivos |
| `net-tools` | Ferramentas de rede |
| `htop` | Monitor de processos |
| `tree` | Visualização de diretórios |

---

### `index.html` — Página Web

Página responsiva com **design moderno** que exibe informações do servidor.

**Variáveis de template** substituídas automaticamente pelo `provisioning.sh`:

| Variável | Valor |
|---|---|
| `{{SERVER_HOSTNAME}}` | Nome do servidor (hostname) |
| `{{SERVER_IP}}` | Endereço IP do servidor |
| `{{PROVISION_DATE}}` | Data e hora do provisionamento |

**Recursos da página:**

- Design responsivo (mobile-first)
- Animações CSS3
- Cards informativos
- Indicador de status online
- Tags de tecnologias utilizadas

---

### `monitor.sh` — Monitoramento

Exibe um **relatório completo** do estado do servidor:

```
📊 MONITORAMENTO DO SERVIDOR WEB

━━━ Status do Apache2 ━━━
  Status: ● Ativo (rodando)
  PID Principal: 1234
  Processos Apache: 5

━━━ Sistema ━━━
  Hostname: meu-servidor
  IP: 192.168.1.100
  Uptime: up 2 days, 3 hours
  Carga: 0.15 0.10 0.05

━━━ Recursos ━━━
  CPU: 12.5%
  Memória: 512MB / 2048MB (25%)
  Disco: Usado: 35% | Livre: 12G

━━━ Portas Ativas ━━━
  Porta 22:  ● Aberta
  Porta 80:  ● Aberta
  Porta 443: ● Aberta

━━━ Últimos 5 Acessos ━━━
  192.168.1.1 | GET / HTTP/1.1 | Status: 200

━━━ Teste de Resposta ━━━
  HTTP Status: 200 OK
  Tempo de resposta: 0.003s
```

---

### `uninstall.sh` — Desinstalação

Remove **completamente** o servidor web com:

- ✅ Confirmação antes de executar
- ✅ Opção de backup dos arquivos
- ✅ Remoção do Apache2 e dependências
- ✅ Limpeza de configurações
- ✅ Limpeza de logs
- ✅ Opção de resetar regras do firewall
- ✅ Relatório do que foi removido

---

## 🔒 Segurança

### Medidas implementadas

| Proteção | Header/Configuração | Função |
|---|---|---|
| **Clickjacking** | `X-Frame-Options: SAMEORIGIN` | Impede que o site seja carregado em iframes |
| **MIME Sniffing** | `X-Content-Type-Options: nosniff` | Previne interpretação incorreta de tipos |
| **XSS** | `X-XSS-Protection: 1; mode=block` | Ativa filtro contra cross-site scripting |
| **Referrer** | `Referrer-Policy: strict-origin` | Controla informações de referência |
| **Versão oculta** | `ServerTokens Prod` | Esconde versão do Apache |
| **Assinatura** | `ServerSignature Off` | Remove assinatura do servidor |
| **Listagem** | `Options -Indexes` | Desabilita listagem de diretórios |
| **Firewall** | `UFW (22, 80, 443)` | Apenas portas essenciais abertas |
| **Arquivos ocultos** | `.htaccess FilesMatch` | Bloqueia acesso a dotfiles |

---

## 🖥️ Demonstração

### Saída do Provisionamento

```
╔══════════════════════════════════════════════════════════╗
║   🌐 PROVISIONAMENTO AUTOMÁTICO DE SERVIDOR WEB 🌐    ║
╚══════════════════════════════════════════════════════════╝

[✔] Verificação de privilégios: OK (root)
[✔] Sistema detectado: Ubuntu 22.04.3 LTS
[✔] Conectividade de rede: OK

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Iniciando provisionamento...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[➤] Atualizando repositórios e pacotes...
[✔] Repositórios atualizados com sucesso
[✔] Pacotes atualizados com sucesso
[➤] Instalando Apache2...
[✔] Apache2 instalado com sucesso
[➤] Instalando pacotes adicionais...
[✔] Pacote 'curl' já instalado
[✔] Pacote 'ufw' instalado
[✔] Pacote 'wget' já instalado
[➤] Configurando Firewall (UFW)...
[✔] Firewall configurado (portas 22, 80, 443)
[➤] Configurando Apache2...
[✔] Módulos habilitados (rewrite, headers, ssl)
[✔] Cabeçalhos de segurança configurados
[✔] VirtualHost configurado
[➤] Publicando página web...
[✔] Página web publicada com sucesso
[➤] Criando .htaccess...
[✔] .htaccess configurado
[➤] Instalando scripts auxiliares...
[✔] monitor.sh instalado em /usr/local/bin/web-monitor.sh
[✔] uninstall.sh instalado em /usr/local/bin/web-uninstall.sh
[➤] Iniciando Apache2...
[✔] Configuração do Apache: Sintaxe OK
[✔] Apache2 habilitado no boot
[✔] Apache2 iniciado com sucesso

╔══════════════════════════════════════════════════════════╗
║                                                        ║
║   ✅ PROVISIONAMENTO CONCLUÍDO COM SUCESSO!            ║
║                                                        ║
║   🌐 Acesse: http://192.168.1.100                      ║
║   📦 Apache: Apache/2.4.52                              ║
║   🔒 Firewall: UFW Ativo                                ║
║   📊 Monitor: sudo web-monitor.sh                      ║
║   🗑️  Remover: sudo web-uninstall.sh                    ║
║   📋 Log: /var/log/provisioning.log                     ║
║                                                        ║
╚══════════════════════════════════════════════════════════╝
```

### Arquivos Criados no Sistema

```
/var/www/html/
├── index.html              # Página web
├── index.html.bak          # Backup da página original
└── .htaccess               # Configurações de cache e segurança

/etc/apache2/
├── conf-available/
│   ├── servername.conf     # ServerName
│   └── security-headers.conf  # Headers de segurança
└── sites-available/
    └── 000-default.conf    # VirtualHost configurado

/usr/local/bin/
├── web-monitor.sh          # Script de monitoramento
└── web-uninstall.sh        # Script de desinstalação

/var/log/
└── provisioning.log        # Log completo do provisionamento
```

---

## ❓ Solução de Problemas

### O script não executa

```bash
# Verificar permissão
chmod +x provisioning.sh

# Verificar se é root
sudo ./provisioning.sh
```

### Apache não inicia

```bash
# Verificar status
sudo systemctl status apache2

# Verificar erros de configuração
sudo apache2ctl configtest

# Ver logs de erro
sudo tail -20 /var/log/apache2/error.log
```

### Página não carrega no navegador

```bash
# Verificar se o Apache está rodando
sudo systemctl is-active apache2

# Verificar se a porta 80 está aberta
sudo ss -tlnp | grep :80

# Verificar regras do firewall
sudo ufw status

# Testar localmente
curl http://localhost
```

### Verificar o log do provisionamento

```bash
# Ver log completo
cat /var/log/provisioning.log

# Ver últimas linhas
tail -30 /var/log/provisioning.log
```

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Uso no Projeto |
|---|---|
| **Bash Script** | Automação e provisionamento |
| **Apache2** | Servidor web HTTP |
| **UFW** | Gerenciamento de firewall |
| **HTML5** | Estrutura da página web |
| **CSS3** | Estilização e animações |
| **Linux** | Sistema operacional base |
| **Git** | Controle de versão |

---

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Faça um **fork** do projeto
2. Crie uma **branch** para sua feature
   ```bash
   git checkout -b feature/minha-feature
   ```
3. Faça **commit** das alterações
   ```bash
   git commit -m "feat: adiciona minha feature"
   ```
4. Faça **push** para a branch
   ```bash
   git push origin feature/minha-feature
   ```
5. Abra um **Pull Request**

---

## 📄 Licença

Este projeto está sob a licença **MIT**. Veja o arquivo [LICENSE](LICENSE) para
mais detalhes.

---

## 👨‍💻 Autor

Desenvolvido por **Otávio Guedes**

<p align="left">
  <a href="https://github.com/Otavio2704">
    <img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" alt="GitHub">
  </a>
  <a href="https://www.linkedin.com/in/otavio-backend2007/">
    <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn">
  </a>
</p>

---

<p align="center">
  Feito com ❤️ e ☕ | Infraestrutura como Código
</p>
