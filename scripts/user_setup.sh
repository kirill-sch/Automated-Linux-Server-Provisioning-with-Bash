generate_file_with_name () {
    echo "username,password" > "../output/$1.csv"; \
    echo "$1,$2" >> "../output/$1.csv"
}

trim_brackets () {
    s="${1#[}"
    s="${s%]}"
    echo "$s"
}

setup_user_and_groups () {    
    username="$(echo "$1"_"$2")" # TODO: doesn't lowercase, special charachters may cause problems
    group_list=$(trim_brackets "$3")
    password="$(makepasswd --chars 10)"
    # TODO: must check if the groups is empty then if it is add user to default group

    echo "Generating user with username: $username"

    sudo useradd -m -G "$group_list" -s /bin/bash "$username" # -m: creates home dir; -s: login shell
    sudo usermod -p "$password" "$username"
    sudo passwd -n 7 "$username" # password can't be changed for given days
    sudo passwd -x 90 "$username" # password remains valid for given days
    sudo passwd -e "$username" # expire password, forced to change password at the next login

    generate_file_with_name $username $password
}

# TODO: add passphase protection
generate_ssh_key () {
    username="$(echo "$1"_"$2")"

    echo "Generating ssh key for username: $username"

    mkdir "../output/ssh_keys/$username"
    ssh-keygen -t rsa -b 2048 -f "../output/ssh_keys/$username/id_rsa"

    cp "../output/ssh_keys/$username" "/home/$username/.ssh/authorized_keys"
    # TODO: chmod and chown change
}

reading_data_from_users_file () {
    while IFS="," read -r column1 column2 column3
    do
        # TODO: create username here so every function gets the same one
        setup_user_and_groups column1 column2 column3
        generate_ssh_key column1 column2 

}

sudo chage 