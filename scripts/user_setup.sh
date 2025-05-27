generate_file_with_name () {
    echo "username,password" > "output/$1.csv"; \
    echo "$1,$2" >> "output/$1.csv"
}

group_create () {
    IFS="," read -r -a GROUP <<< "$1"
    for i in "${GROUP[@]}"; do
        output=$(getent group "$i")

        if [[ -n $output ]]; then # if group is already created then skip creation
            continue
        else 
            echo "Creating group: $i"
            sudo addgroup "$i"   
        fi
    done 
}

setup_user_and_groups () {      
    username=$4  
    group_list=$3
    password="$(makepasswd --chars 10)"
    # TODO: must check if the groups is empty then if it is add user to default group

    echo "Generating user with username: $username"

    group_create "$group_list"

    sudo useradd -m -G "$group_list" -s /bin/bash "$username" # -m: creates home dir; -s: login shell
    getent passwd "$username"

    echo "$username:$password" | sudo chpasswd
    sudo passwd -n 7 "$username" # password can't be changed for given days
    sudo passwd -x 90 "$username" # password remains valid for given days
    sudo passwd -e "$username" # expire password, forced to change password at the next login

    generate_file_with_name "$username" "$password"
}
