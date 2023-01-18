#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

sudo unlink /etc/nginx/sites-enabled/default
sudo chmod 777 /etc/nginx/sites-available

sudo echo 'server {
    listen 80;
    location / {
        proxy_pass "http://'$1':80";
    }
}' > /etc/nginx/sites-available/reverse-proxy.conf

sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
sudo service nginx restart

# sudo chmod 777 /var/www/html
# sudo chmod 777 /var/www/html/index.nginx-debian.html
# sudo echo "<h1>Hello World! - Nathan from EC2-${HOSTNAME}</h1>" > /var/www/html/index.nginx-debian.html
#sudo systemctl restart nginx

