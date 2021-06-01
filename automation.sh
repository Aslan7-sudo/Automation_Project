

#!/bin/bash
Name=Nikhil
Bucket=upgrad-nikhilmanthineedi

#Script updates the package information

sudo apt-get update -y

#installing AWSCLI 

sudo apt install awscli -y

#Script ensures that the HTTP Apache server is installed

which apache2 

Check=$(echo $?)

if [[ $Check == *1* ]]; then
        sudo apt install apache2  -y
else 
        echo "Apache is isntalled"
fi

#Script ensures that HTTP Apache server is running

Status=$(systemctl status apache2.service)

if [[ $Status == *"-k start"* ]]; then
        echo "Apache Server is Running"
else
        systemctl start apache2.service
fi

#Script verifies whether apache2 service is enabled at the startup or not. if not the code below enables it
Verify=$(sudo systemctl list-unit-files --type=service --state=enabled --all)

if [[ $Verify == *"apache2.service"* ]]; then 
        echo "Apache2 is enabled at startup"
else
	sudo update-rc.d apache2 defaults
fi 

#Creating a tar file for logs in apache2
cd /var/log/apache2 

timestamp=$(date '+%d%m%Y-%H%M%S')

tar -cvf /tmp/"$Name-httpd-logs-$timestamp.tar"  ./access.log ./error.log
SIZE=$(du -h /tmp/$Name-httpd-logs-$timestamp.tar | awk '{print $1}') 

#Archiving logs to S3

aws s3 \
cp /tmp/$Name-httpd-logs-${timestamp}.tar \
s3://$Bucket/$Name-httpd-logs-${timestamp}.tar


#Searching for inventory.html in the folder if found okay if not create the file

cd /var/www/html

search=$(ls)

if  [[ $search == *"inventory.html"* ]]; then
        echo "Inventory File found"
else 
        cd /var/www/html && touch inventory.html   
	echo "<!DOCTYPE html>
		<html>
		<body>

		<table style="width:100%">
		  <tr>
		    <th>Log Type</th>
		    <th>Time Created</th> 
		    <th>Type</th>
		    <th>Size</th>
		  </tr>
		</table>
		</body>
		</html>" > inventory.html 

	echo "New Inventory file Created"
fi




echo  "<!DOCTYPE html>
                <html>
                <body>

                <table style="width:100%">
                  <tr>
                    <th>${name}-httpd</th>
                    <th>${timestamp}</th> 
                    <th>.tar</th>
                    <th>$SIZE</th>
                  </tr>
                </table>
                </body>
                </html>" >> inventory.html



CRON=$(systemctl status cron)

if [[ $CRON == *"active (running)"* ]];then
	echo "Cron is active and running"
else
	apt-get install cron
fi

cd /etc/cron.d

CronV=$(ls)

if [[ $CronV == *"automation"* ]];then
	echo "Automation Cronjob is Available"
else 
	touch automation
	echo  " 0 0 * * * /root/Automation_Project/automation.sh" > automation
fi

