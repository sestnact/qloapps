#!/bin/bash
# terminate on errors
set -e
# Banner
echo "-------------------------------------------------------";
echo ".-----.-----.-----.|  |_.-----.---.-.----.|  |_ 
|__ --|  -__|__ --||   _|     |  _  |  __||   _|
|_____|_____|_____||____|__|__|___._|____||____|"
echo "-------------------------------------------------------";
echo "Start container web server..."
echo "-------------------------------------------------------";
# Check if volume is empty
if [ ! "$(ls -A "/var/www/qloapps" 2>/dev/null)" ]; then
    echo "Setting up volume!"
    # Copy qloapps from Qloapps src to volume
    cp -r /usr/src/qloapps /var/www/
    chown -R www-data:www-data /var/www/qloapps
    echo "<=========================>"
    echo "Setting up volume done!"
fi
echo "-------------------------------------------------------"
#restart apache2
service apache2 restart
# check if apache is running
echo "Starting apache webserver ....."
if [ ! "$(pstree | grep apache2 > /dev/null)" ];then
    echo "Apache2 status - OK"
else
    echo "Apache2 start - FAILED"
fi
echo "-------------------------------------------------------"
#restart php-fpm
service php7.4-fpm restart
# check if php-fpm is running
echo "Starting php-fpm module ......."
if [ ! "$(pstree | grep php > /dev/null)" ];then
    echo "PHP-FPM status - OK"
else
    echo "PHP-FPM start - FAILED"
fi
echo "-------------------------------------------------------"
exec "$@"