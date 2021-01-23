Configure the Security Groups, Route Tables, and NACL

Verify the NACL permits port 22 for SSH and port 3306 for MySQL/Aurora.
Verify two route tables exist: one utilizing an internet gateway and another with no IGW/NAT routes.
Verify the private subnet is associated with the route table that does not contain an internet gateway.
Verify the public subnet is associated with the route table that does contain an internet gateway.
Create a new security group containing rules to permit port 22 and 3306 from 0.0.0.0/0, and assign this security group to the EC2 bastion.


Set Up an EC2 Instance for SSH Tunneling

Create an EC2 instance, ensuring you select the previously created security group with rules for ports 22 and 3306.
During the instance creation process, download the .pem key file, as this will be used to establish a connection to the EC2 instance.
Using your downloaded key, log in to your EC2 instance via SSH to verify connectivity.

Create an RDS Aurora Database

Create a T2.small RDS Aurora database, ensuring the database is launched in a private subnet.
Ensure the security group associated with the RDS Aurora database permits traffic on TCP 3306.
Use MySQL Workbench to verify connectivity, ensuring the Connection Method is set to Standard TCP/IP over SSH, and SSH Key File is set to your previously downloaded .pem key.

RDS Proxy
https://aws.amazon.com/rds/proxy/
https://aws.amazon.com/about-aws/whats-new/2020/04/amazon-rds-proxy-with-postgresql-compatibility-preview/
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-rds-dbproxy.html

// тут консольные команды чтоб подключиться
https://aws.amazon.com/premiumsupport/knowledge-center/rds-aurora-mysql-connect-proxy/

1) 
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html#rds-proxy-secrets-arns
!!! IAM Permissions
https://www.terraform.io/docs/providers/aws/r/secretsmanager_secret_version.html
2) 




https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html#rds-proxy-secrets-arns
https://aws.amazon.com/blogs/compute/using-amazon-rds-proxy-with-aws-lambda/

https://github.com/terraform-providers/terraform-provider-aws/issues/12690#issue-595077362
https://aws.amazon.com/about-aws/whats-new/2019/12/amazon-rds-proxy-available-in-preview/
https://aws.amazon.com/about-aws/whats-new/2020/04/amazon-rds-proxy-with-postgresql-compatibility-preview/


Как включить 
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html


https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/rds-proxy.html


https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.html


https://aws.amazon.com/blogs/database/use-iam-authentication-to-connect-with-sql-workbenchj-to-amazon-aurora-mysql-or-amazon-rds-for-mysql
https://aws.amazon.com/premiumsupport/knowledge-center/rds-aurora-mysql-connect-proxy/
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.html
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html#rds-proxy-secrets-arns
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html
https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/rds-proxy.html
https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.Connecting.AWSCLI.html



