#!/bin/bash

#!/bin/bash

# Update package index
sudo apt update

# Install necessary packages
sudo apt install -y software-properties-common git
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update

# Install required packages
sudo apt install -y apache2 mysql-server php7.4 php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring php7.4-xml php7.4-xmlrpc

# Secure MySQL installation
sudo mysql_secure_installation

# Prompt for database password
read -sp "Enter a password for the DVWA database user: " DB_PASSWORD
echo

# Create DVWA database and user
sudo mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE dvwadb;
CREATE USER 'dvwa'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON dvwadb.* TO 'dvwa'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT


# Download DVWA
cd /var/www/html
sudo git clone https://github.com/ethicalhack3r/DVWA.git

# Set permissions
sudo chmod -R 777 /var/www/html/DVWA/hackable/uploads/
sudo chmod 666 /var/www/html/DVWA/external/phpids/0.6/lib/IDS/tmp/phpids_log.txt
sudo chmod 777 /var/www/html/DVWA/config

# Copy and configure DVWA
sudo cp /var/www/html/DVWA/config/config.inc.php.dist /var/www/html/DVWA/config/config.inc.php
sudo sed -i "s/$_DVWA\['db_server'\] = 'localhost';/$_DVWA\['db_server'\] = '127.0.0.1';/" /var/www/html/DVWA/config/config.inc.php
sudo sed -i "s/$_DVWA\['db_database'\] = 'dvwa';/$_DVWA\['db_database'\] = 'dvwadb';/" /var/www/html/DVWA/config/config.inc.php
sudo sed -i "s/$_DVWA\['db_user'\] = 'root';/$_DVWA\['db_user'\] = 'dvwa';/" /var/www/html/DVWA/config/config.inc.php
sudo sed -i "s/$_DVWA\['db_password'\] = 'p@ssw0rd';/$_DVWA\['db_password'\] = '$DB_PASSWORD';/" /var/www/html/DVWA/config/config.inc.php


sudo sed -i "s|DocumentRoot /var/www/html|DocumentRoot /var/www/html/DVWA|" /etc/apache2/sites-enabled/000-default.conf

# Restart services
sudo systemctl restart apache2
sudo systemctl restart mysql

echo "DVWA installation completed. Access it at http://localhost"
