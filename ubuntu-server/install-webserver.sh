#!/bin/bash

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Function to install Apache
install_apache() {
    echo "Installing Apache web server..."
    apt update
    apt install -y apache2
    systemctl enable apache2
    systemctl start apache2
    echo "Apache web server installed and started."
}

# Function to install Nginx
install_nginx() {
    echo "Installing Nginx web server..."
    apt update
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "Nginx web server installed and started."
}

# Prompt the user to choose between Apache and Nginx
echo "Which web server do you want to install?"
echo "1 = Nginx"
echo "2 = Apache"
read -p "(default: 1) Enter your choice: " choice

case "$choice" in
    1|"")
        if is_installed nginx; then
            echo "Nginx is already installed."
        else
            install_nginx
        fi
        ;;
    2)
        if is_installed apache2; then
            echo "Apache is already installed."
        else
            install_apache
        fi
        ;;
    *)
        echo "Invalid choice. Please choose 1 for Nginx or 2 for Apache."
        ;;
esac

