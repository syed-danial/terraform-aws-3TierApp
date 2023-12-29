#!/bin/bash
sudo yum update -y
sudo yum install git -y
#sudo yum install nginx -y
sudo amazon-linux-extras install nginx1

cd /etc/nginx/
sudo rm nginx.conf

cd /home/ec2-user
git clone https://github.com/aws-samples/aws-three-tier-web-architecture-workshop.git
cd /home/ec2-user/aws-three-tier-web-architecture-workshop/application-code/

sudo mv web-tier /home/ec2-user/
sed -i "s/\[REPLACE-WITH-INTERNAL-LB-DNS\]/${internal_lb_dns}/g" nginx.conf
sudo mv nginx.conf /etc/nginx/
sudo rm -rf /home/ec2-user/aws-three-tier-web-architecture-workshop

cd /home/ec2-user
export HOME=/home/ec2-user

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

source /home/ec2-user/.bashrc
nvm install 16 -y
nvm use 16

cd /home/ec2-user/web-tier/
npm install
npm run build

sudo service nginx restart
chmod -R 755 /home/ec2-user
sudo chkconfig nginx on