https://app.linuxacademy.com/hands-on-labs/c1da328a-dd5d-4fb5-904f-f9e89603d017?redirect_uri=https:%2F%2Flinuxacademy.com%2Fcp%2Fmodules%2Fview%2Fid%2F241

https://app.linuxacademy.com/hands-on-labs/c1da328a-dd5d-4fb5-904f-f9e89603d017?redirect_uri=https:%2F%2Flinuxacademy.com%2Fcp%2Fmodules%2Fview%2Fid%2F241

Additional Information and Resources
Log in to the live AWS environment using the credentials provided. Make sure you're in the N. Virginia (us-east-1) region throughout the lab.

The file containing the Bash script for this hands-on lab is located in the downloads section of this course, or you can use the following link to access the file:

https://linuxacademy.com/cp/guides/download/refsheets/guides/refsheets/basic-apacheinstall-bash_1540027005.txt

Or copy and paste the below:

#!/bin/bash
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
Learning Objectives
check_circle
Create and Configure an Application Load Balancer

Create and configure an Application Load Balancer.
Choose name.
Select only HTTP and select both Availability Zones.
Choose existing security group.
Choose name for target group.
Under Advanced Settings: 3,2,5,10 to speed IP our timeouts. (Remember the ALS is looking for a 200 status code to pass the health checks.)
Ignore all error messages.
check_circle

Create and Configure an Auto Scaling Group

In the EC2 console, under Auto Scaling, select Launch Configurations.
Choose AMI, and add a launch configuration name.
Under Advanced Details, paste in the provided Bash script to configure our EC2 instance as a web server.
Make sure to select Assign a public IP address to every instance.
Choose the existing security group.
Create a new key pair, and download it somewhere safe.
Click Create Auto Scaling group.
Add a name, make sure to choose the VPC with two subnets, change the health checks to 180 seconds, use scaling policies for 1 and 3, and choose CPU usage and set it to 80%.
Now edit by selecting Actions.
Add your target group and update your desired capacity to 2 and a minimum of 2, and click Save.
check_circle


Create and Configure a CNAME Alias in Route 53

In Route 53, select the provided hosted zone.
Click Create a Record Set.
Choose name, set the Type to A*, select *Yes for Alias, and then select our recently created Application Load Balancer, simple routing, and leave the health checks as default.
Copy your new alias and open a new webpage to verify that the alias serves our Apache test page.
