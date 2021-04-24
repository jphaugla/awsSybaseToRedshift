# awsSybaseToRedshift
## Purpose

Demonstrates installing Sybase ASE to an redhat 8 EC2 instance and using this as source for DMS to migrate to Redshift
start up environment

## Overview

Cloud formation template to create a Windows EC2 to run the Schema Conversion Tool, a redhat EC2 instance to run Sybase ASE, target Redshift database and the DMS components to do the migration
Good blog on using [Sybase ASE as a source](https://aws.amazon.com/blogs/database/migrating-from-sap-ase-to-amazon-aurora-postgresql/)

## Outline

- [Overview](#overview)
- [AWS Services Used](#aws-services-used)
- [Technical Overview](#technical-overview)
- [Instructions](#instructions)
  - [Create Environment](#create-environment)
  - [Sybase Installation](#sybase-installation)
  - [Verify Databases](#verify-databases)
- [Windows Steps](#windows-steps)
- [SCT](#SCT)
- [Complete DMS Steps](#complete-dms-steps)
## AWS Services Used

* [AWS DMS Database Migration Service](https://aws.amazon.com/dms/)
* [AWS SCT Schema Conversion Tool](https://aws.amazon.com/dms/schema-conversion-tool/)
* [AWS Cloudformation](https://aws.amazon.com/cloudformation/)
* [AWS Redshift](https://aws.amazon.com/redshift/)

## Technical Overview

* Bring up DMS/SCT environment using modified immersion days template
* Review Security Group Settings
* Install Sybase SAE and create sample Sybase ASE database
* Use SCT and DMS to convert sample Sybase ASE database to redshift
* handy links
    * short link and video on installation
https://www.sybase.r2schools.com/sybase-ase-16-installation-on-linux/
    * sybase link on installation
http://infocenter.sybase.com/help/index.jsp?topic=/com.sybase.infocenter.dc35892.1600/doc/html/jon1256241632272.html
    * another installation link
https://help.sap.com/doc/c929440cdf914db1b5c3de3f32dbdba5/16.0.3.2/en-US/SAP_ASE_AWS.pdf
    * Best installation detail link
https://help.sap.com/doc/a6167530bc2b1014a88ec21bab8c671f/16.0.4.0/en-US/SAP_ASE_Installation_Guide_Linux_en.pdf
    * link to download software
https://www.sap.com/cmp/td/sap-ase-enterprise-edition-trial.html

## Instructions
***IMPORTANT NOTE**: Creating this demo application in your AWS account will create and consume AWS resources, which **will cost money**.  Costing information is available at [AWS DMS Pricing](https://aws.amazon.com/dms/pricing/)   The template will cost money for the other resources as well.

### Create Environment
Go to CloudFormation and create a stack with the cloudformation yaml file in ./templates/awsSybaseRedshift.yaml

### Sybase Installation
* Download Sybase SAP ASE tar file from [link](https://www.sap.com/cmp/td/sap-ase-enterprise-edition-trial.html)
* copy TAR file to EC2 instance
```bash
scp  -i ~/.ssh/yourpem.pem ASE_Suite.linuxamd64.tar ec2-user@<the ec2 ip>:/home/ec2-user
```
* create a software directory, copy the tar file to the software directory, untar the binary, edit the response file to make sample database, and run the install
```bash
sudo bash
mkdir ../software
mkdir ../software/sybaseASE
mv ASE_Suite.linuxamd64.tar ../software/sybaseASE/
chmod 755 ../software/
chown ec2-user:ec2-user ../software/sybaseASE/
cd ../software/sybaseASE/
tar -xvf ASE_Suite.linuxamd64.tar
cd ebf29650
cat sample_response.txt | sed '/SY_CFG_ASE_SAMPLE_DB=false/ s/false/true/' | sed '/SY_CFG_ASE_MASTER_DEV_SIZE=/ s/52/2000/' |  sed '/SY_CFG_ASE_MASTER_DB_SIZE=/ s/26/1000/' | sed '/SY_CFG_ASE_PAGESIZE=/ s/4k/8k/' > response.txt
nohup ./setup.bin -f response.txt -i silent -DAGREE_TO_SAP_LICENSE=true -DRUN_SILENT=true > install.out 2>&1 &
```
* verify installation was successful by first finding servers and then logging in
```bash
cd /opt/sap
source SYBASE.sh
# show servers
$SYBASE/$SYBASE_ASE/install/showserver
# login
isql -Usa -SSYBASE -PSybase123
1> select @@version
2> go
```
* manually install sample databases (not necessary if changed above)
cd 
### Verify Databases
Handy Sybase cheat sheet [link](http://www.dbatodba.com/sybase/how-tos/sysbase-commands/)
this will first show all the database, use the pubs2 database, list all tables in pub and then select all rows from author
```bash
isql -Usa -SSYBASE -PSybase123 
sp_helpdb
go
use pubs2
go
sp_help
go
select * from authors
go
```
```bash
isql -Usa -SSYBASE -PSybase123 
1> sp_setreptable authors, 'true'
2> go
1> sp_setreptable stores, 'true'
2> go
1> sp_setreptable blurbs, 'true'
2> go
1> sp_setreptable publishers, 'true'
2> go
1> sp_setreptable discounts, 'true'
2> go
1> sp_setreptable salesdetail, 'true'
2> go
1> sp_setreptable titles, 'true'
2> go
1> sp_setreptable titleauthor, 'true'
2> go
1> sp_setreptable
2> go
1> dbcc settrunc('ltm', 'valid')
2> go
```

## Windows Steps
* Use the internal IP address for the EC2instance to connect using RDP
* Download [Toad for Sybase](https://www.quest.com/register/55632/)
* Install Toad and login to Toad
* Use Linux Server Host IP, Port 5000, User: sa and Password: Sybase123


### SCT
####  this part is not needed for Redshift as neither RedShift or MS SQLServer are SCT targets when using Sybase ASE as a source
Able to verify connectivity to Sybase using SCT and can convert to postgresql but not helpful for this use case

* copy the jdbc driver and directories from the Linux server at /opt/sap/jConnect-16_0 to the ./Desktop/DMS Workship/JDBC directory

Return back to the DMS and SCT steps using the SQL Server to Amazon Aurora PostgreSQL

* Start back at this point in the [guide](https://dms-immersionday.workshop.aws/en/sqlserver-aurora-postgres.html)
* Perform the following Part 1 Schema Conversion Steps: "Connect to the EC2 Instance", "Install the AWS Schema Conversion Tool (AWS SCT)"
* Create a New Project using New Project Wizard 
* Connect to Sybase 
    * jar driver is in ./Desktop/DMS Workship/JDBC/jConnect-16_0 
* Accept the risks
* Under the "pubs2" database on the left panel, click on the dbo schema  and click "Next" to generate the assessment report
* Click Next and enter parameters for Aurora PostgreSQL connection 
    * To find the password, look back in the original templates/DMSWorkshop.yaml in the repository home
    * Click "Finish"
* Right click on the "dbo" schema in the left panel and select Convert Schema to generate the data definition language (DDL) statements for the target database.
* Right click on the dbo schema in the right-hand panel, and click Apply to

### Complete DMS Steps
The cloudFormation script does not support setting up the DMS endpoint for DocumentDB.  Using CLI bash scripts for the remaining setup
* NOTE:  each of these scripts needs to have the ARNs corrected for your current environment.  So, the createDocDBEndpoint.sh needs the documentDB cluster ARN and the ARN of the created cerficate.  The createReplicationTask.sh needs the ARN for the dynamoDB endpoint, the documentDB endpoint, and the replication instance ARN.
```bash
cd templates
# add IAM roles
./createRedshiftRole.sh
./createS3Policy.sh
# create the endpoint for redshift target
# edit the redshift-settings.json file for the correct endpoint in the ServerName
./createRedshiftEndpoint.sh
# edit the sybase-settings.json file for the correct LinuxInstance private IP address in the ServerName
# create the sybase endpoint after editing the script for the LinuxInstance private IP address
./createSybaseEndpoint.sh
# edit the pertinent arns for the source endpoint, target endpoint, replication instance and then run the create replication scripts
./createReplicationTask.sh
# edit the start replication script for ARN of the replication task
./startReplication.sh
```
### Results

Should see the bulk load tables statistics when clicking on the table statistics tab for the database migration task.

Insert additional rows to see the change data capture move those rows to the target

```bash
isql -Usa -SSYBASE -PSybase123 
1> use pubs2
2> go
1> insert into authors values ('111-11-1111', 'Olson', 'Jeremiah', '612-888-2323', '1111 Waltrup Road', 'Minneapolis', 'MN', 'USA', '55407')
2> go
(1 row affected)
1> commit
2> go
```
