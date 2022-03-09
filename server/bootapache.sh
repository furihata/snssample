echo "export RDS_HOSTNAME=$RDS_HOSTNAME" >> /etc/apache2/envvars
echo "export RDS_USERNAME=$RDS_USERNAME" >> /etc/apache2/envvars
echo "export RDS_PASSWORD=$RDS_PASSWORD" >> /etc/apache2/envvars
apachectl -D FOREGROUND