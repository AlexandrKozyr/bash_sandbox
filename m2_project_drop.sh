#!/bin/bash
#script drops existed m2 instance by removing its folders, database and host entry
# arguments:
# $1 - existed project


PROJECTROOT="/var/www/magento2/$1"

#delete project folder
rm -rf $PROJECTROOT
#delete DB
mysql -h0.0.0.0 -uadmin -padmin -e "drop database $1"
#remove host from hosts
sed -i "/^.*$1.magento2.local/d" /etc/hosts
wait$!
docker exec -i nginx nginx -s reload
wait$!

echo "Project $1 successfully removed"
