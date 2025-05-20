install_packages () {
    echo "Installing packages for: $1"
    sudo apt-get -y --ignore-missing install "$1"
}

update_packages () {
    sudo apt update
    sudo apt upgrade -y
}

install_docker () {
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
        # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

reading_data_from_packages_file () {
    update_packages

    while IFS="," read -r package
    do
        if [[ "$package" == "docker" ]]; then
            echo "Installing packages for: Docker"
            install_docker
        else
            install_packages "$package"
        fi
    done < config/packages.csv
}