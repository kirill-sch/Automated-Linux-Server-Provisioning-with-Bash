install_packages () {
    sudo apt-get -y --ignore-missing install "$1"
}

update_packages () {
    sudo apt update
    sudo apt upgrade
}

reading_data_from_packages_file () {
    while IFS="," read -r package
    do
        install_packages "$package"
    done < config/packages.csv
}
