#!/bin/bash

set -x
#set -e

source ./scripts/user_setup.sh
source ./scripts/ssh_keys.sh
source ./scripts/install_packages.sh


reading_data_from_users_file () {
    #dos2unix config/users.csv  # this might solve the issue that it doesn't read lines further then the first; it might not be needed with the new solution to get the values  
    counter=1
    while read line 
    do
        counter=$((counter + 1))

        firstName=( $(tail -n +"$counter" config/users.csv | cut -d ',' -f1))
        lastName=( $(tail -n +"$counter" config/users.csv | cut -d ',' -f2))
        groups=( $(tail -n +"$counter" config/users.csv | cut -d ',' -f3- | sed -e 's/\"//g' -e 's/\[//g' -e 's/\]//g' )) # the sed replaces the " and [] characters to nothing
        username="${firstName}_${lastName}" # TODO: doesn't lowercase, special charachters may cause problems
        
        echo "$firstName $lastName $groups $username"
        
        #reading_data_from_packages_file
        setup_user_and_groups "$firstName" "$lastName" "$groups" "$username"
        generate_ssh_key "$username"
    done < config/users.csv
}

reading_data_from_users_file