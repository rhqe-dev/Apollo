#!/bin/bash

# ── Colours ────────────────────────────────────────────────────────────────────
GRN='\033[0;32m'
PUR='\033[0;35m'
YEL='\033[0;33m'
CYN='\033[0;36m'
RED='\033[0;31m'
WHT='\033[1;37m'
DIM='\033[2m'
RST='\033[0m'

BAR="${DIM}──────────────────────────────────────────────────────────────${RST}"

# ── OS / distro detection ──────────────────────────────────────────────────────
# Package manager + per-distro package name overrides
PKG_MANAGER=""
PKG_UPDATE=""
PKG_INSTALL=""
PKG_SCREEN="screen"
PKG_SQLITE="sqlite3"
PKG_NGINX="nginx"
PKG_CERTBOT="certbot"
PKG_CERTBOT_NGINX="python3-certbot-nginx"
NEEDS_EPEL=0
INIT_SYSTEM="systemd"
SVC_RELOAD_NGINX=""
SVC_ENABLE_CERTBOT=""
OS_PRETTY=""

detect_os() {
    local id="" id_like="" ver=""

    if [ -f /etc/os-release ]; then
        id="$(       . /etc/os-release && printf '%s' "${ID,,}"           )"
        id_like="$(  . /etc/os-release && printf '%s' "${ID_LIKE,,}"      )"
        ver="$(       . /etc/os-release && printf '%s' "${VERSION_ID%%.*}" )"
        OS_PRETTY="$( . /etc/os-release && printf '%s' "$PRETTY_NAME"     )"
    elif [ -f /etc/redhat-release ]; then
        id="rhel"; OS_PRETTY="$(cat /etc/redhat-release)"
    elif [ -f /etc/debian_version ]; then
        id="debian"; OS_PRETTY="Debian $(cat /etc/debian_version)"
    fi
    [ -z "$OS_PRETTY" ] && OS_PRETTY="Unknown Linux"

    # ── Match by $ID ──────────────────────────────────────────────────────────
    case "$id" in
        ubuntu|debian|linuxmint|pop|kali|raspbian|elementary|mx|zorin|parrot|deepin|neon)
            PKG_MANAGER="apt"
            PKG_UPDATE="apt-get update -y"
            PKG_INSTALL="apt-get install -y"
            ;;
        fedora)
            PKG_MANAGER="dnf"
            PKG_UPDATE="dnf check-update -y; true"
            PKG_INSTALL="dnf install -y"
            PKG_CERTBOT_NGINX="certbot-nginx"
            ;;
        centos|rhel|rocky|almalinux|ol|scientific|amzn)
            if command -v dnf &>/dev/null; then
                PKG_MANAGER="dnf"
                PKG_UPDATE="dnf check-update -y; true"
                PKG_INSTALL="dnf install -y"
            else
                PKG_MANAGER="yum"
                PKG_UPDATE="yum check-update -y; true"
                PKG_INSTALL="yum install -y"
            fi
            PKG_CERTBOT_NGINX="certbot-nginx"
            NEEDS_EPEL=1
            ;;
        arch|manjaro|endeavouros|garuda|artix|cachyos)
            PKG_MANAGER="pacman"
            PKG_UPDATE="pacman -Sy --noconfirm"
            PKG_INSTALL="pacman -S --noconfirm --needed"
            PKG_SQLITE="sqlite"
            PKG_CERTBOT_NGINX="certbot-nginx"
            ;;
        alpine)
            PKG_MANAGER="apk"
            PKG_UPDATE="apk update"
            PKG_INSTALL="apk add --no-cache"
            PKG_SQLITE="sqlite"
            PKG_CERTBOT_NGINX="certbot-nginx"
            INIT_SYSTEM="openrc"
            ;;
        opensuse*|sles|sle*)
            PKG_MANAGER="zypper"
            PKG_UPDATE="zypper --non-interactive refresh"
            PKG_INSTALL="zypper --non-interactive install"
            PKG_CERTBOT_NGINX="python3-certbot-nginx"
            ;;
        void)
            PKG_MANAGER="xbps"
            PKG_UPDATE="xbps-install -Su"
            PKG_INSTALL="xbps-install -y"
            PKG_CERTBOT_NGINX="certbot-nginx"
            INIT_SYSTEM="runit"
            ;;
        gentoo)
            PKG_MANAGER="emerge"
            PKG_UPDATE="emerge --sync"
            PKG_INSTALL="emerge"
            PKG_SCREEN="app-misc/screen"
            PKG_SQLITE="dev-db/sqlite"
            PKG_NGINX="www-servers/nginx"
            PKG_CERTBOT="app-crypt/certbot"
            PKG_CERTBOT_NGINX="app-crypt/certbot-nginx"
            INIT_SYSTEM="openrc"
            ;;
        *)
            # ── Fallback 1: check ID_LIKE ──────────────────────────────────
            if echo "$id_like" | grep -qE "debian|ubuntu"; then
                PKG_MANAGER="apt"; PKG_UPDATE="apt-get update -y"; PKG_INSTALL="apt-get install -y"
            elif echo "$id_like" | grep -qE "rhel|fedora|centos"; then
                if command -v dnf &>/dev/null; then
                    PKG_MANAGER="dnf"; PKG_UPDATE="dnf check-update -y; true"; PKG_INSTALL="dnf install -y"
                else
                    PKG_MANAGER="yum"; PKG_UPDATE="yum check-update -y; true"; PKG_INSTALL="yum install -y"
                fi
                PKG_CERTBOT_NGINX="certbot-nginx"; NEEDS_EPEL=1
            elif echo "$id_like" | grep -q "arch"; then
                PKG_MANAGER="pacman"; PKG_UPDATE="pacman -Sy --noconfirm"; PKG_INSTALL="pacman -S --noconfirm --needed"
                PKG_SQLITE="sqlite"; PKG_CERTBOT_NGINX="certbot-nginx"
            elif echo "$id_like" | grep -q "suse"; then
                PKG_MANAGER="zypper"; PKG_UPDATE="zypper --non-interactive refresh"; PKG_INSTALL="zypper --non-interactive install"
            # ── Fallback 2: probe available binaries ─────────────────────
            elif command -v apt-get  &>/dev/null; then
                PKG_MANAGER="apt"; PKG_UPDATE="apt-get update -y"; PKG_INSTALL="apt-get install -y"
            elif command -v dnf      &>/dev/null; then
                PKG_MANAGER="dnf"; PKG_UPDATE="dnf check-update -y; true"; PKG_INSTALL="dnf install -y"
                PKG_CERTBOT_NGINX="certbot-nginx"; NEEDS_EPEL=1
            elif command -v yum      &>/dev/null; then
                PKG_MANAGER="yum"; PKG_UPDATE="yum check-update -y; true"; PKG_INSTALL="yum install -y"
                PKG_CERTBOT_NGINX="certbot-nginx"; NEEDS_EPEL=1
            elif command -v pacman   &>/dev/null; then
                PKG_MANAGER="pacman"; PKG_UPDATE="pacman -Sy --noconfirm"; PKG_INSTALL="pacman -S --noconfirm --needed"
                PKG_SQLITE="sqlite"; PKG_CERTBOT_NGINX="certbot-nginx"
            elif command -v apk      &>/dev/null; then
                PKG_MANAGER="apk"; PKG_UPDATE="apk update"; PKG_INSTALL="apk add --no-cache"
                PKG_SQLITE="sqlite"; PKG_CERTBOT_NGINX="certbot-nginx"; INIT_SYSTEM="openrc"
            elif command -v zypper   &>/dev/null; then
                PKG_MANAGER="zypper"; PKG_UPDATE="zypper --non-interactive refresh"; PKG_INSTALL="zypper --non-interactive install"
            elif command -v xbps-install &>/dev/null; then
                PKG_MANAGER="xbps"; PKG_UPDATE="xbps-install -Su"; PKG_INSTALL="xbps-install -y"
                PKG_CERTBOT_NGINX="certbot-nginx"; INIT_SYSTEM="runit"
            else
                PKG_MANAGER="unknown"
            fi
            ;;
    esac

    # ── Service management ────────────────────────────────────────────────────
    # Prefer systemd even on distros that default to OpenRC (e.g. Gentoo with systemd)
    if command -v systemctl &>/dev/null && systemctl --version &>/dev/null 2>&1; then
        INIT_SYSTEM="systemd"
        SVC_RELOAD_NGINX="systemctl reload nginx"
        SVC_ENABLE_CERTBOT="systemctl enable --now certbot.timer"
    elif command -v rc-service &>/dev/null; then
        INIT_SYSTEM="openrc"
        SVC_RELOAD_NGINX="rc-service nginx reload"
        SVC_ENABLE_CERTBOT=""   # falls back to cron below
    else
        SVC_RELOAD_NGINX="nginx -s reload"
        SVC_ENABLE_CERTBOT=""
    fi
}

detect_os

# ── Root check ─────────────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}✖  Please run as root.${RST}"
    exit 1
fi

if [ "$PKG_MANAGER" = "unknown" ]; then
    echo -e "${RED}✖  Unsupported distro — could not detect a package manager.${RST}"
    echo -e "${DIM}   Manually install: screen, sqlite3, nginx, certbot — then re-run.${RST}"
    exit 1
fi

# Resolve directory this script lives in so it works from any cwd
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

clear
echo ""
echo -e "  ${WHT}APOLLO CNC${RST}  ${DIM}//  startup${RST}"
echo -e "  ${BAR}"
echo -e "  ${DIM}System : ${OS_PRETTY}${RST}"
echo -e "  ${DIM}Distro : pkg=$(printf '%-8s' "$PKG_MANAGER")  init=${INIT_SYSTEM}${RST}"
echo ""

# ── Config prompt ──────────────────────────────────────────────────────────────
CONFIG="resources/settings/config.json"

# Read current values so we can show them as defaults
CURRENT_KEY="$(grep -oP '(?<="key":\s")([^"]+)' "$CONFIG" 2>/dev/null)"
CURRENT_NAME="$(grep -oP '(?<="cncName":\s")([^"]*)' "$CONFIG" 2>/dev/null)"

echo -e "  ${CYN}CNC Auth Key${RST}  ${DIM}(current: ${CURRENT_KEY:-unset})${RST}"
echo -ne "  ${WHT}▸  Enter key (leave blank to keep): ${RST}"
read -r INPUT_KEY
echo ""

echo -e "  ${CYN}CNC Name${RST}  ${DIM}(current: ${CURRENT_NAME:-unset})${RST}"
echo -ne "  ${WHT}▸  Enter name (leave blank to keep): ${RST}"
read -r INPUT_NAME
echo ""

# Write non-empty inputs into config.json using a temp file + mv (atomic)
TMP="$(mktemp)"
cp "$CONFIG" "$TMP"

if [ -n "$INPUT_KEY" ]; then
    # Replace "key": "<anything>" inside the auth block
    sed -i "s|\"key\":\s*\"[^\"]*\"|\"key\": \"${INPUT_KEY}\"|g" "$TMP"
fi

if [ -n "$INPUT_NAME" ]; then
    sed -i "s|\"cncName\":\s*\"[^\"]*\"|\"cncName\": \"${INPUT_NAME}\"|g" "$TMP"
fi

mv "$TMP" "$CONFIG"
echo -e "  ${GRN}✔  Config updated.${RST}"
echo ""

# ── Dependencies ───────────────────────────────────────────────────────────────
DEPS_MISSING=0
for dep in screen sqlite3 nginx certbot; do
    command -v "$dep" > /dev/null 2>&1 || { DEPS_MISSING=1; break; }
done

if [ $DEPS_MISSING -eq 1 ]; then
    echo -e "  ${GRN}▶  Installing dependencies  ${DIM}(${PKG_MANAGER})${RST}${GRN}...${RST}"

    # RHEL-family: ensure EPEL is available before installing certbot/nginx
    if [ "$NEEDS_EPEL" -eq 1 ]; then
        if ! rpm -q epel-release &>/dev/null; then
            echo -e "  ${DIM}    Enabling EPEL repository...${RST}"
            $PKG_INSTALL epel-release > /dev/null 2>&1
        fi
    fi

    eval "$PKG_UPDATE" > /dev/null 2>&1
    $PKG_INSTALL \
        "$PKG_SCREEN" \
        "$PKG_SQLITE" \
        "$PKG_NGINX"  \
        "$PKG_CERTBOT" \
        "$PKG_CERTBOT_NGINX" > /dev/null 2>&1

    echo -e "  ${GRN}✔  Dependencies installed.${RST}"
else
    echo -e "  ${GRN}✔  Dependencies already installed — skipping.${RST}"
fi
echo ""

# ── Nginx + SSL setup ──────────────────────────────────────────────────────────
EXISTING_DOMAIN="$(grep -oP '(?<=server_name\s)[^;]+' /etc/nginx/sites-available/apollo 2>/dev/null | awk '{print $1}')"
DOMAIN_CONFIGURED=0
if [ -n "$EXISTING_DOMAIN" ] && [ -f "/etc/letsencrypt/live/${EXISTING_DOMAIN}/fullchain.pem" ]; then
    DOMAIN_CONFIGURED=1
fi

if [ $DOMAIN_CONFIGURED -eq 1 ]; then
    echo -e "  ${GRN}✔  Domain already configured: ${EXISTING_DOMAIN}${RST}"
    echo -ne "  ${WHT}▸  Reconfigure domain? [Y/N]: ${RST}"
    read -r DOMAIN_CHOICE
    echo ""
else
    echo -ne "  ${WHT}▸  Set up custom domain for API? [Y/N]: ${RST}"
    read -r DOMAIN_CHOICE
    echo ""
fi

if [[ "${DOMAIN_CHOICE}" =~ ^[Yy]$ ]]; then
    echo -e "  ${CYN}Nginx / SSL Domain${RST}  ${DIM}(current: ${EXISTING_DOMAIN:-not configured})${RST}"
    echo -ne "  ${WHT}▸  Enter domain: ${RST}"
    read -r INPUT_DOMAIN
    echo ""

    if [ -n "$INPUT_DOMAIN" ]; then
    # Read web port from config.json (default 8080 if missing)
    WEB_PORT="$(grep -oP '(?<="webPort":\s)\d+' "$CONFIG" 2>/dev/null)"
    WEB_PORT="${WEB_PORT:-8080}"

    echo -e "  ${GRN}▶  Configuring nginx for ${INPUT_DOMAIN}...${RST}"

    # Write initial nginx config (HTTP only) for certbot to validate
    cat > /etc/nginx/sites-available/apollo <<NGINXEOF
server {
    listen 80;
    server_name ${INPUT_DOMAIN};

    # Block all direct HTTP access — only used for ACME challenge
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 444;
    }
}
NGINXEOF

    ln -sf /etc/nginx/sites-available/apollo /etc/nginx/sites-enabled/apollo
    rm -f /etc/nginx/sites-enabled/default 2>/dev/null

    nginx -t > /dev/null 2>&1 && $SVC_RELOAD_NGINX > /dev/null 2>&1
    echo -e "  ${GRN}✔  Nginx configured.${RST}"
    echo ""

    # Obtain certificate
    echo -e "  ${GRN}▶  Obtaining SSL certificate for ${INPUT_DOMAIN}...${RST}"
    certbot certonly --nginx \
        --non-interactive \
        --agree-tos \
        --register-unsafely-without-email \
        -d "${INPUT_DOMAIN}" > /dev/null 2>&1
    CERT_STATUS=$?

    if [ $CERT_STATUS -eq 0 ]; then
        echo -e "  ${GRN}✔  Certificate issued.${RST}"
        echo ""

        # Write final nginx config: HTTPS proxy + block plain HTTP
        cat > /etc/nginx/sites-available/apollo <<NGINXEOF
# Drop all plain HTTP traffic (no redirect — hard block)
server {
    listen 80 default_server;
    server_name _;
    return 444;
}

server {
    listen 443 ssl;
    server_name ${INPUT_DOMAIN};

    ssl_certificate     /etc/letsencrypt/live/${INPUT_DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${INPUT_DOMAIN}/privkey.pem;

    # Modern TLS only
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Proxy to Apollo web port
    location / {
        proxy_pass         http://127.0.0.1:${WEB_PORT};
        proxy_http_version 1.1;
        proxy_set_header   Host              \$host;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
NGINXEOF

        nginx -t > /dev/null 2>&1 && $SVC_RELOAD_NGINX > /dev/null 2>&1
        echo -e "  ${GRN}✔  HTTPS proxy active — https://${INPUT_DOMAIN}${RST}"

        # Ensure certbot auto-renewal is registered (systemd timer or cron fallback)
        if [ -n "$SVC_ENABLE_CERTBOT" ]; then
            $SVC_ENABLE_CERTBOT > /dev/null 2>&1 || \
                (crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet --nginx") | crontab - > /dev/null 2>&1
        else
            (crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet --nginx") | crontab - > /dev/null 2>&1
        fi
        echo -e "  ${GRN}✔  Certificate auto-renewal enabled.${RST}"
    else
        echo -e "  ${RED}✖  Certificate request failed. Check that ${INPUT_DOMAIN} points to this server's IP.${RST}"
        echo -e "  ${DIM}    Nginx left in HTTP-only ACME mode. Re-run after fixing DNS.${RST}"
    fi
    fi  # end input domain check
    echo ""
fi  # end domain choice

# ── Permissions + DB setup ─────────────────────────────────────────────────────
echo -e "  ${PUR}▶  Installing + Setting Up DB...${RST}"
chmod +x apollo
chmod +x loop.sh
echo -e "  ${PUR}✔  Done.${RST}"
echo ""

# ── Kill stale sessions ────────────────────────────────────────────────────────
echo -e "  ${YEL}▶  Killing any existing Apollo sessions...${RST}"
screen -ls | awk '/\.apollo\t/{print $1}' | xargs -r -I{} screen -S {} -X quit 2>/dev/null
# Fallback: send quit directly by name in case the awk pattern missed it
screen -S apollo -X quit > /dev/null 2>&1 || true
sleep 0.5
echo -e "  ${YEL}✔  Done.${RST}"
echo ""

# ── First-run credentials ──────────────────────────────────────────────────────
# apollo --print-creds skips auth, opens the DB, runs first-run init and prints
# APOLLO_ROOT_PASS=<pw> if this is a fresh install, then exits immediately.
CREDS_LINE="$(timeout 10 ./apollo --print-creds 2>/dev/null)"
if [ -n "$CREDS_LINE" ]; then
    TEMP_PASS="${CREDS_LINE#APOLLO_ROOT_PASS=}"
    echo -e "  ${BAR}"
    echo ""
    echo -e "  ${WHT}First run detected — root account created.${RST}"
    echo ""
    echo -e "  ${CYN}  Username :${RST}  root"
    echo -e "  ${CYN}  Password :${RST}  ${WHT}${TEMP_PASS}${RST}  ${DIM}(temporary — change on first login)${RST}"
    echo ""
    echo -e "  ${BAR}"
    echo ""
fi

# ── Launch ─────────────────────────────────────────────────────────────────────
export TERM=xterm-256color
screen -dmS apollo bash loop.sh

echo -e "  ${GRN}✔  Apollo CNC launched.${RST}"
echo ""
echo -e "  ${BAR}"
echo ""
echo -e "  ${YEL}Attach with:  screen -r apollo${RST}"
echo ""
