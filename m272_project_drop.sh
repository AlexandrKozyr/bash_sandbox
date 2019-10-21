#!/bin/bash
#script drops existed m2 instance by removing its folders, database and host entry
# arguments:
# $1 - existed project

if [[ -z "$1" ]]
  then
    echo "Please specify the project name as parameter."
    exit 1
fi

PROJECTROOT="/var/www/magento272/$1"

#delete project folder
rm -rf $PROJECTROOT
#delete DB
mysql -h0.0.0.0 -uadmin -padmin -e "drop database $1"
#remove host from hosts
sed -i "/^.*$1.magento272.local/d" /etc/hosts
wait$!
docker exec -i nginx nginx -s reload
wait$!

echo "Project $1 successfully removed"
