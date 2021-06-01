# Automation_Project

This Code is a Bash script to automate the installation of a web server (Apache) on a Linux machine and create a tar file of the logs access.log and error.log (Name for logfiles: name and timestamp) present in apache server and dumb them in s3 buket
The data of the logs are appended to a file called inventory.html which is created in /var/www/html directory
we create a cron job in script to run the above funtionalities daily
