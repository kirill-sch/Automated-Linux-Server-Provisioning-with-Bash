#!/bin/bash

set -x

source ./scripts/user_setup.sh
source ./scripts/ssh_keys.sh
source ./scripts/install_packages.sh
source ./scripts/backup.sh


regex_checker () {
    for var in "$@"
    do
        if [[ ! "$var" =~ ^[A-Za-z]+$ ]]; then
            echo "first and last name can only contain alphabetic characters: $var"
            exit 0
        fi
    done
}

reading_data_from_users_file () {
    selectedOption=$1
    counter=1

    # Extract values from the csv file
    while read line 
    do
        counter=$((counter + 1))

        firstName=( $(tail -n +"$counter" config/users.csv | cut -d ',' -f1))
        lastName=( $(tail -n +"$counter" config/users.csv | cut -d ',' -f2))
        groups=( $(tail -n +"$counter" config/users.csv | cut -d ',' -f3- | sed -e 's/\"//g' -e 's/\[//g' -e 's/\]//g' )) # the sed replaces the " and [] characters to nothing
        username="$(echo "$firstName" | tr '[:upper:]' '[:lower:]')_$(echo "$lastName" | tr '[:upper:]' '[:lower:]')"

        regex_checker "$firstName" "$lastName"  

        if [[ "$selectedOption" == "1" ]]; then
            setup_user_and_groups "$username" "$groups"
        else
            generate_ssh_key "$username"
        fi
    done < config/users.csv
}

main () {
    run="true"

    while [[ "$run" == "true" ]]; do
        echo "1) Exit"
        echo "2) Create users"
        echo "3) Create SSH keys"
        echo "4) Install packages"
        echo "5) Backup files"

        read -p "Choose an option: " choice

        case $choice in
            1) exit 0 ;;
            2) reading_data_from_users_file 1 ;;
            3) reading_data_from_users_file 2 ;;
            4) reading_data_from_packages_file ;;
            5) create_backup ;;
            *) echo "Invalid option." ;;
        esac
    done
}

main