#!/bin/bash

################################################################################
# Author: Mouhssine EL
# Project: projet-DILL 2023
# Date: 04-02-2024
################################################################################
# Set working directory
WORKDIR="/opt/gophish"
mkdir -p $WORKDIR
mkdir $WORKDIR/logs

cp * $WORKDIR
cd $WORKDIR

# Function to run commands with error redirection
cmd_generate_error() {
    if [ $? != 0 ]; then
        /usr/bin/echo -e "[$cl_red-$cl_df]$cl_red ERROR$cl_df during : $1"
        if [ $3 = "true" ]; then
            exit
        fi
    else
        if [ $2 = "true" ]; then
            /usr/bin/echo -e "[$cl_green+$cl_df]$cl_green OK$cl_df during : $1"
        fi
    fi
}

# Run setup-gophish.sh
/bin/bash setup-gophish.sh
cmd_generate_error "setup-gophish.sh" "true" "false"

# Copy formation-phishing.com.conf to /etc/apache2/sites-available/
cp formation-phishing.com.conf /etc/apache2/sites-available/
cmd_generate_error "Copy formation-phishing.com.conf" "true" "false"

# Run gophish-as-service.sh
/bin/bash gophish-as-service.sh
cmd_generate_error "gophish-as-service.sh" "true" "false"

# Run setup-apache-and-website.sh
/bin/bash setup-apache-and-website.sh
cmd_generate_error "setup-apache-and-website.sh" "true" "false"

# Replace contents of apache2.conf with provided configuration
sudo tee /etc/apache2/apache2.conf < apache2.conf
#cat apache2.conf > /etc/apache2/apache2.conf
cmd_generate_error "Replace apache2.conf" "true" "false"

cd $WORKDIR
# Create modules.txt file
cat <<EOT >> modules.txt
alias.load
authn_file.load
authz_core.load
auth_host.load
authz_user.load
autoindex.load
deflate.conf
dir.conf
env.load
expires.load
filter.load
headers.load
mime.conf
mime.load
mpm_event.conf
mpm_event.load
negotiation.conf
proxy.conf
proxy_http.load
proxy_http2.load
proxy_ajp.load
proxy_balancer.load
proxy_connect.load
proxy_express.load
proxy_fcgi.load
proxy_fdpass.load
proxy_scgi.load
proxy_wstunnel.load
rewrite.load
setenvif.conf
setenvif.load
socache_dbm.load
socache_memcache.load
socache_shmcb.load
ssl_module
status.conf
status.load

EOT
cmd_generate_error "Create modules.txt" "true" "false"

# Replace contents of ports.conf with provided configuration
cat ports.conf > /etc/apache2/ports.conf
cmd_generate_error "Replace ports.conf" "true" "false"

# Reload Apache to apply changes
systemctl reload apache2
cmd_generate_error "Reload Apache" "true" "false"

echo -e "\nInstallation completed successfully."
