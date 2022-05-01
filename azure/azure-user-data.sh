#! /bin/bash
sudo setenforce 0
sudo systemctl restart httpd
sudo systemctl restart mariadb