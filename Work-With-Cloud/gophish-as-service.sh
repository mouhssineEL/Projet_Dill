#!/bin/bash

################################################################################
# Author: Mouhssine EL
# Project: projet-DILL 2023
# Date: 04-02-2024
################################################################################

# Define work directory for gophish, adapt this to your system
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

#---------------------------------------
#cat  /etc/systemd/system/gophish.service 
#sudo -s # login as superUser

sudo echo -e  "
[Unit]
Description=Gophish service
After=network-online.target
StartLimitInterval=3

[Service]

User=root
Environment="GOPHISH_BIN_PATH=$WORKDIR"
Environment="GOPHISH_LOG_PATH=$WORKDIR/logs/"
ExecStart=/bin/bash $WORKDIR/gophish.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/gophish.service
cmd_generate_error "Create file service " "true" "true"
# change permissions of service
sudo chmod 777 /etc/systemd/system/gophish.service

# Create the executable to run gophish
echo -e "
#!/bin/bash

GOPHISH_LOG_FILE=gophish.log
GOPHISH_ERR_FILE=gophish.err

check_bin_path() {
    if [[ -z "$GOPHISH_BIN_PATH" ]]; then
        exit 1
    fi
}

check_log_path() {
    if [[ -z "$GOPHISH_LOG_PATH" ]]; then
        exit 2
    fi
}

create_new_log_err() {
    GOPHISH_STAMP=`date +%Y%m%d%H%M%S-%N`
    if [[ -e $GOPHISH_LOG_PATH$GOPHISH_LOG_FILE ]]; then
        mv $GOPHISH_LOG_PATH$GOPHISH_LOG_FILE $GOPHISH_LOG_PATH$GOPHISH_LOG_FILE-$GOPHISH_STAMP
    fi
    
    if [[ -e $GOPHISH_LOG_PATH$GOPHISH_ERR_FILE ]]; then
        mv $GOPHISH_LOG_PATH$GOPHISH_ERR_FILE $GOPHISH_LOG_PATH$GOPHISH_ERR_FILE-$GOPHISH_STAMP
    fi
    
    touch $GOPHISH_LOG_PATH$GOPHISH_LOG_FILE
    touch $GOPHISH_LOG_PATH$GOPHISH_ERR_FILE
}

launch_gophish() {
    cd $GOPHISH_BIN_PATH
    ./gophish >> $GOPHISH_LOG_PATH$GOPHISH_LOG_FILE 2>> $GOPHISH_LOG_PATH$GOPHISH_ERR_FILE
}

check_bin_path
check_log_path 
create_new_log_err
launch_gophish
" >> $WORKDIR/gophish.sh || chmod +x $WORKDIR/gophish.sh

cmd_generate_error "Run executable" "true" "false"

# Start and Make the service on the boot 
sudo systemctl daemon-reload > /dev/null
cmd_generate_error " Daemon on" "true" "false"

sudo systemctl enable gophish > /dev/null
cmd_generate_error "Enable service gophish" "true" "false"

sudo systemctl start gophish > /dev/null
cmd_generate_error "Starting gophish"  "true" "true"

