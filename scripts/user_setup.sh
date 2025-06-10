generate_file_with_name () {
    echo "username,password" > "output/$1.csv"; \
    echo "$1,$2" >> "output/$1.csv"
}

group_create () {
    IFS="," read -r -a GROUP <<< "$1"
    for i in "${GROUP[@]}"; do
        output=$(getent group "$i")

        if [[ -n "$output" ]]; then 
            continue
        else
            if [[ ! "$i" =~ ^[A-Za-z]+$ ]]; then
            echo "group names can only contain alphabetic characters: $i"
            exit 0
            fi
              
            echo "Creating group: $i"
            sudo addgroup "$i"   
        fi
    done 
}

setup_user_and_groups () {      
    username="$1"
    groups="$2"
    password="$(makepasswd --chars 10)"    

    echo "Generating user with username: $username"

    if [[ -z "$groups" ]]; then
        sudo useradd -m -s /bin/bash "$username"
    else
        group_create "$groups"
        sudo useradd -m -G "$groups" -s /bin/bash "$username" # -m: creates home dir; -s: login shell
    fi

    echo "$username:$password" | sudo chpasswd # add password
    sudo passwd -n 7 "$username" # password can't be changed for given days
    sudo passwd -x 90 "$username" # password remains valid for given days
    sudo passwd -e "$username" # expire password, forced to change password at the next login

    generate_file_with_name "$username" "$password"
}
