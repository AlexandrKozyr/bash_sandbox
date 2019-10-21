#!/bin/bash
#script creates magento2 OS project with sample data (should be used with Magecom dockers )
# requirements
# 1. auth.json with assess to the repo.magento.com in the php71
# arguments:
# $1 - valid magento OS version
# $2 - project name (used for folder and host name);
# $3 - 0/1 install sample data or not

PROJECTROOT="/var/www/magento272/$2"

#create project
docker exec -i php72 composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$1 $PROJECTROOT
wait$!
docker exec -i php72 bash -c "cd $PROJECTROOT && composer install"
wait$!

#create DB
mysql -h0.0.0.0 -uadmin -padmin -e "create database $2"
wait$!

#add hosts
echo "127.0.0.1    $2.magento272.local"  >> /etc/hosts
wait$!
docker exec -i nginx nginx -s reload
wait$!

#install project
docker exec -i php72 bash -c "cd $PROJECTROOT && bin/magento setup:install --base-url="https://$2.magento272.local/" --db-host="mysql" --db-name="$2" --db-user="admin" --db-password="admin" --admin-firstname="admin" --admin-lastname="admin" --admin-email="user@example.com" --admin-user="admin" --admin-password="admin123" --language="en_US" --currency="USD" --timezone="America/Chicago" --use-rewrites="1" --backend-frontname="admin""
wait$!
chmod -R  777 /var/www/magento272/$2
wait$!
if [[ $3 == 1 ]];then
docker exec -i php72 bash -c "cp /home/apache/.composer/auth.json $PROJECTROOT/auth.json"
docker exec -i php72 bash -c "cd $PROJECTROOT && bin/magento sampledata:deploy"
wait$!
fi
docker exec -i php72 bash -c "cd $PROJECTROOT && bin/magento set:up"

echo "________________________________________________________"
echo "--------------------------------------------------------"

echo "Project successfully built - $2.magento272.local"
echo "admin url - $2.magento272.local/admin"
echo "admin pass - admin"
echo "admin pass - admin123"

echo "________________________________________________________"
echo "--------------------------------------------------------"