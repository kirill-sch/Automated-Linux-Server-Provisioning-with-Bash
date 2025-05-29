source ./.env

ssh_connection_with_backup_server () {   
    # this function should check if there's already an SSH connection established

    echo "$SERVER_NAME $SERVER_USER $SERVER_IP"
    

    mkdir "output/ssh_keys/$SERVER_NAME"
    #sudo chmod 600 "output/ssh_keys/$SERVER_NAME"

    ls -l "output/ssh_keys/$SERVER_NAME"

    # retrieves the public SSH host key of the backup server and appends the key to the trusted host files; -H: Hash the hostames in the output
    ssh-keyscan -H "$SERVER_IP" >> ~/.ssh/known_hosts

    ssh-keygen -t rsa -b 2048 -f "output/ssh_keys/$SERVER_NAME/$SERVER_NAME" -q -N ""
    ssh-copy-id -i "output/ssh_keys/$SERVER_NAME/$SERVER_NAME.pub" "$SERVER_USER"@"$SERVER_IP"
}

set_up_crontab_for_backup () {    
    # write out current crontab (even if crontab is empty!), echo new cron into cron file and install the new file
    crontab -l > backups_crontab
    echo "0 * * * * /usr/local/bin/backup_crontab.sh" >> backups_crontab
    crontab backups_crontab
    rm backups_crontab
}

backup_with_rsync () {
    DATE=$(date '+%F') # date in YYYY-MM-DD format

    # push everything from the main_server's '/' directory except excluded directories
    # -a: archive mode, -H: preserve hard links, -z: compress
    rsync --dry-run --numeric-ids -aHz -e "ssh -i output/ssh_keys/$SERVER_NAME/$SERVER_NAME" \
    --exclude=/dev/* \
    --exclude=/proc/* \
    --exclude=/sys/* \
    --exclude=/tmp/* \
    --exclude=/run/* \
    --exclude=/mnt/* \
    --exclude=/media/* \
    --exclude=/cdrom/* \
    --exclude=/lost+found/* \
    --exclude=/var/tmp/* \
    / "$SERVER_USER"@"$SERVER_IP":"/home/$SERVER_USER/backups/$DATE"
}

create_backup () {    
    echo "$SERVER_NAME $SERVER_USER $SERVER_IP"

    # .env is used by the backup_crontab so it should be persistent
    sudo cp .env /etc/backup.env

    # the backup_crontab.sh will be ran by the created crontab so it has to be available at all times
    sudo mkdir -p /usr/local/bin
    sudo chmod 755 /usr/local/bin
    sudo cp scripts/backup_crontab.sh /usr/local/bin
    sudo chmod +x /usr/local/bin/backup_crontab.sh 

    ssh_connection_with_backup_server 

    #backup_with_rsync

    #set_up_crontab_for_backup
}