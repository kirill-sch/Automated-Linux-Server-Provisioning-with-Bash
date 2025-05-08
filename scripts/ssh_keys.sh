# TODO: add passphase protection
generate_ssh_key () {
    username=$1

    echo "Generating ssh key for username: $username"

    mkdir "../output/ssh_keys/$username"    
    ssh-keygen -t rsa -b 2048 -f "../output/ssh_keys/$username"

    mkdir -p "/home/$username/.ssh"
    sudo chmod 700 "/home/$username/.ssh"

    cp "../output/ssh_keys/$username.pub" "/home/$username/.ssh/authorized_keys"
    sudo chmod 600 "/home/$username/.ssh/authorized_keys"
    sudo chown -R "$username":"$username" "/home/$username/.ssh/authorized_keys"
}