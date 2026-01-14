#!/usr/bin/with-contenv bashio

# Get admin password from options
ADMIN_PASSWORD=$(bashio::config 'admin_password')

# Create persistent storage directory
CUPS_CONFIG="/data/cups"
mkdir -p "${CUPS_CONFIG}/etc" "${CUPS_CONFIG}/var"

# Link CUPS directories to persistent storage
if [ ! -L "/etc/cups" ]; then
    rm -rf /etc/cups
    ln -sf "${CUPS_CONFIG}/etc" /etc/cups
fi

if [ ! -L "/var/spool/cups" ]; then
    rm -rf /var/spool/cups
    ln -sf "${CUPS_CONFIG}/var" /var/spool/cups
fi

# Configure CUPS
echo "Configuring CUPS..."

# Set admin password
useradd -r -G lpadmin -M cupsdmin 2>/dev/null || true
echo "cupsdmin:${ADMIN_PASSWORD}" | chpasswd

# Only create cupsd.conf if it doesn't exist (preserve existing config)
if [ ! -f "${CUPS_CONFIG}/etc/cupsd.conf" ]; then
    bashio::log.info "Creating initial CUPS configuration..."
    mkdir -p "${CUPS_CONFIG}/etc"
    cat > "${CUPS_CONFIG}/etc/cupsd.conf" << 'EOF'
# Server settings
LogLevel warn
MaxLogSize 0
ServerName 0.0.0.0

# Listen on all interfaces
Port 631
Listen /run/cups/cups.sock

# Share printers on the local network
Browsing On
BrowseLocalProtocols dnssd

# Web interface settings
WebInterface Yes

# Default authentication type
DefaultAuthType Basic

# Allow access from local network
<Location />
  Order allow,deny
  Allow @LOCAL
</Location>

<Location /admin>
  Order allow,deny
  Allow @LOCAL
</Location>

<Location /admin/conf>
  AuthType Default
  Require user @SYSTEM
  Order allow,deny
  Allow @LOCAL
</Location>

# Set the default printer options
<Policy default>
  JobPrivateAccess default
  JobPrivateValues default
  SubscriptionPrivateAccess default
  SubscriptionPrivateValues default
  <Limit All>
    Order deny,allow
  </Limit>
</Policy>
EOF
else
    bashio::log.info "Using existing CUPS configuration..."
fi

# Start CUPS in foreground
bashio::log.info "Starting CUPS Print Server..."
bashio::log.info "Web interface available at http://homeassistant.local:631"
bashio::log.info "Print service available at http://homeassistant.local:5000"
bashio::log.info "Username: cupsdmin"
bashio::log.info "Password: ${ADMIN_PASSWORD}"

# Start avahi for printer discovery in background
avahi-daemon --daemonize 2>/dev/null || bashio::log.warning "Could not start avahi-daemon"

# Start print service in background
python3 /print_service.py &

exec cupsd -f
