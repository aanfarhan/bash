#!/bin/bash

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Function to add the PHP repository if not already added
add_php_repository() {
    if ! grep -q "^deb .*$1" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
        add-apt-repository -y $1
    else
        echo "Repository $1 already added."
    fi
}

# Function to install PHP with specified version
install_php() {
    local version=$1
    apt update
    apt install -y php$version php$version-fpm php$version-common php$version-bcmath \
    php$version-xml php$version-zip php$version-curl php$version-gd php$version-tokenizer \
    php$version-intl php$version-pgsql php$version-dev php$version-mbstring
}

# Check if software-properties-common is installed
if ! is_installed software-properties-common; then
    apt update
    apt install -y software-properties-common
fi

# Add PHP repository if not already added
add_php_repository "ppa:ondrej/php"

# Prompt the user to choose the PHP version
echo "Select PHP version to install (e.g., 8.0, 7.4, etc.):"
read php_version

# Call the function with the chosen version
install_php $php_version

echo "PHP $php_version installation complete."

