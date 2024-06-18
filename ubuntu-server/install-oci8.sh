#!/bin/bash

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Function to check if Oracle Instant Client is installed
is_instantclient_installed() {
    [ -d /opt/oracle/instantclient ] && [ -f /opt/oracle/instantclient/libclntsh.so ]
}

# Check and perform steps 1 to 5 if not already done
if ! is_instantclient_installed; then
    # Download Oracle Instant Client
    echo "Downloading Oracle Instant Client..."
    wget -q https://github.com/aanfarhan/instantclient/raw/main/linux/12.1.zip -O /tmp/instantclient.zip

    # Create directory for Oracle Instant Client
    echo "Creating directory /opt/oracle..."
    mkdir -p /opt/oracle

    # Unzip and move Oracle Instant Client
    echo "Unzipping Oracle Instant Client..."
    unzip -q /tmp/instantclient.zip -d /tmp/
    mv /tmp/instantclient_12_1 /opt/oracle/instantclient

    # Rename .so.12.1 files to .so
    echo "Renaming .so.12.1 files to .so..."
    cd /opt/oracle/instantclient
    for file in *.so.12.1; do
        ln -sf $file $(echo $file | sed 's/.12.1//')
    done

    # Create ldconfig configuration file and reload ldconfig
    echo "Creating ldconfig configuration file and reloading ldconfig..."
    echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf
    ldconfig
else
    echo "Oracle Instant Client is already installed. Skipping steps 1 to 5."
fi

# Install libaio1 package if not already installed
if ! is_installed libaio1; then
    echo "Installing libaio1 package..."
    apt update
    apt install -y libaio1
fi

# Function to install and enable OCI8 for a PHP version
install_oci8() {
    local version=$1
    local oci8_version=$2
    echo "Installing OCI8 $oci8_version for PHP $version..."
    echo "instantclient,/opt/oracle/instantclient" | pecl install oci8-$oci8_version

    # Create oci8.ini file
    echo "Creating oci8.ini file for PHP $version..."
    echo "; configuration for php oci8 module
; priority=20
extension=oci8.so" > /etc/php/$version/mods-available/oci8.ini

    # Enable OCI8 extension
    echo "Enabling OCI8 extension for PHP $version..."
    phpenmod -v $version -s ALL oci8
}

# Get list of installed PHP versions
php_versions=$(ls /etc/php/ | grep -E '^[0-9]\.[0-9]$')

# Loop through PHP versions and install the appropriate OCI8 version
for version in $php_versions; do
    if [[ $version == 8.1 ]]; then
        install_oci8 $version "3.2.1"
    elif [[ $version == 8.0 ]]; then
        install_oci8 $version "3.0.1"
    elif [[ $version == 7.* ]]; then
        install_oci8 $version "2.2.0"
    elif [[ $version == 5.6 ]]; then
        install_oci8 $version "2.0.10"
    fi
    # Uninstall the current OCI8 version before proceeding to the next one
    pecl uninstall -r oci8
done

echo "OCI8 installation and configuration complete for all installed PHP versions."

