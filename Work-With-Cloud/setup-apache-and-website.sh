#!/bin/bash

################################################################################
# Author: Mouhssine EL
# Project: projet-DILL 2023
# Date: 04-02-2024
################################################################################

# Set working directory
WORKDIR="/opt/gophish"
# Create the path for our website
path_WebSite="/var/www/formation-phishing"

# Create the path for our websitepath_WebSite="//www/formation-phishing"
# Check if the directory exists and delete it
if [ -d "$path_WebSite" ]; then
	sudo rm -rf $path_WebSite
fi
# Create a new website directory
sudo mkdir $path_WebSite
echo -e "New website directory created"

# Function to run commands with error redirection
cmd_generate_error() {
	if [ $? != 0 ]
	then
		/usr/bin/echo -e "[$cl_red-$cl_df]$cl_red ERROR$cl_df during : $1"
		if [ $3 = "true" ]
		then
			exit
		fi
	else
		if [ $2 = "true" ]
		then
			/usr/bin/echo -e "[$cl_green+$cl_df]$cl_green OK$cl_df during : $1"
		fi
	fi
}

# Install dependencies
sudo apt install apache2 &>/dev/null
cmd_generate_error "apache installation" "true" "true"


# We add our  index.html first
# Copy index HTML page
sudo cp -r index.html $path_WebSite/index.html
cmd_generate_error "First page creation" "true" "false"

# Set ownership of the directory to www-data user and www-data group
sudo chown -R www-data:www-data $path_WebSite
cmd_generate_error "change owner" "true" "true"

# CREATION DE VIRTUALHOST/ 
###### Add our  domain to /etc/hosts
echo -e "127.0.0.1 formation-phishing.com " >> /etc/hosts
cmd_generate_error "add domain" "true" "true"
# Creating an apache config file for our website
# Please copy the file named "formation-phishing.com.conf" to /etc/apache2/sites-available/

# download all the need modules
modules_file="modules.txt"
cd $WORKDIR

#if [ -f "$modules_file" ]; then
#  while IFS= read -r module; do
#    sudo a2enmod "$module"
#  done < "$modules_file"
#else
#  echo "Error: modules.txt file not found"
#  exit 1
#fi

# Reload apache to apply the changes
sudo systemctl reload apache2

# Enable the virtual host configuration for our website
sudo a2ensite formation-phishing.com.conf
cmd_generate_error "Enable virtual host configuration" "true" "true"

# Reload apache to apply the changes
sudo systemctl reload apache2
cmd_generate_error "Reload apache2" "true" "true"

echo -e "Your website has been configured"