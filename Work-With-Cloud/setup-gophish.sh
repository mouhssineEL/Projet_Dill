#!/bin/bash

################################################################################
# Author: Mouhssine EL
# Project: projet-DILL 2023
# Date: 03-02-2024
################################################################################

# Make sure to replace "your_public_ip_address_here" with the actual public
# IP address of your server before running the script.
# To save the script as a file, you can copy and paste the script into a
# text editor like Notepad or TextEdit, and then save the file with a .sh extension.
# After saving the file, you can make it executable with the following command: 
# chmod +x setup-gophish.sh
# And then run the script with: 
# sudo sh setup-gophish.sh
################################################################################

# Set public IP address
PUBLIC_IP="0.0.0.0" # Change this to your actual public IP address if it's different

# Set working directory
WORKDIR="/opt/gophish"



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


# Update the system
apt update -y &> /dev/null
cmd_generate_error "System update " "true" "true"

# Install dependencies
apt install git -y &>/dev/null
cmd_generate_error "Git Installation " "true" "true"
apt install unzip -y &>/dev/null
cmd_generate_error "unzip installation " "true" "true"
apt install jq -y &>/dev/null
cmd_generate_error "jq (JSON parser) installation" "true" "false"

# Change to working directory
cd "$WORKDIR"

# Check if Gophish is already installed
if [ ! -f "gophish-v0.12.1-linux-64bit.zip" ]; then
    wget https://github.com/gophish/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip -q
    cmd_generate_error "Gophish download" "true" "true"
fi

# If the download was successful
unzip -qq gophish-v0.12.1-linux-64bit.zip 
cmd_generate_error "Unzip the file" "true" "false"

# Change the IP address to expose the external network interface for Gophish
jq '.admin_server.listen_url= "'"$PUBLIC_IP:3333"'"' config.json | sudo jq '.phish_server.listen_url = "'"0.0.0.0:8080"'"' > temp.json && sudo mv temp.json config.json
cmd_generate_error "Change the IP " "true" "true"
# Add execute permissions to binary
chmod +x gophish

# Clean up
rm gophish-v0.12.1-linux-64bit.zip

cmd_generate_error "Gophish setup completed successfully." "false" "false"

