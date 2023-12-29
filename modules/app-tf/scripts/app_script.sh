#!/bin/bash
sudo yum update -y

sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
echo "[mysql-community]" | sudo tee /etc/yum.repos.d/mysql-community.repo
echo "name=MySQL Community Server" | sudo tee -a /etc/yum.repos.d/mysql-community.repo
echo "baseurl=https://repo.mysql.com/yum/mysql-8.0-community/el/7/\$basearch/" | sudo tee -a /etc/yum.repos.d/mysql-community.repo
echo "enabled=1" | sudo tee -a /etc/yum.repos.d/mysql-community.repo
echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/mysql-community.repo
echo "gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql" | sudo tee -a /etc/yum.repos.d/mysql-community.repo

sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo yum install mysql-community-server -y
sudo systemctl start mysqld
sudo yum install git -y
sudo yum install stress -y

rds_endpoint="${rds_writer_endpoint}"
rds_username="$(aws secretsmanager get-secret-value --secret-id ${secret_username} --query "SecretString" --output text --region ${region})"
rds_password="$(aws secretsmanager get-secret-value --secret-id ${secret_password} --query "SecretString" --output text --region ${region})"
database_name = "${database_name}"


echo "DEBUG: database_name = ${database_name}" >> /var/log/user-data.log

mysql -h $rds_endpoint -u $rds_username -p$rds_password -e "CREATE DATABASE IF NOT EXISTS ${database_name};USE ${database_name};CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL AUTO_INCREMENT, amount DECIMAL(10,2), description VARCHAR(100), PRIMARY KEY(id));INSERT INTO transactions (amount,description) VALUES ('400','groceries');"
cd /home/ec2-user/
git clone https://github.com/aws-samples/aws-three-tier-web-architecture-workshop.git
cd /home/ec2-user/aws-three-tier-web-architecture-workshop/application-code/
sudo mv app-tier /home/ec2-user/
sudo rm -rf /home/ec2-user/aws-three-tier-web-architecture-workshop

database_name = "${database_name}"
new_content="module.exports = Object.freeze({
DB_HOST : '$rds_endpoint',
DB_USER : '$rds_username',
DB_PWD : '$rds_password',
DB_DATABASE : '${database_name}'
});"
echo "$new_content" > /home/ec2-user/app-tier/DbConfig.js
cd /home/ec2-user
export HOME=/home/ec2-user
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
source /home/ec2-user/.bashrc
nvm install 16 -y
nvm use 16
npm install -g pm2
sudo chown -R ec2-user:ec2-user /home/ec2-user/app-tier
cd /home/ec2-user/app-tier
npm install
pm2 start index.js
pm2 list
pm2 startup
sudo env PATH=$PATH:/home/ec2-user/.nvm/versions/node/v16.20.2/bin /home/ec2-user/.nvm/versions/node/v16.20.2/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user
pm2 save