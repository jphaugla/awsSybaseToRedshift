# awsSybaseToRedshift
##  THIS IS NOT READY YET
## Purpose

Demonstrates installing Sybase ASE to an redhat 8 EC2 instance and using this as source for DMS to migrate to Redshift
start up environment

## Overview

Cloud formation template to create a Windows EC2 to run the Schema Conversion Tool, a redhat EC2 instance to run Sybase ASE, target Redshift database and the DMS components to do the migration

## Outline

- [Overview](#overview)
- [AWS Services Used](#aws-services-used)
- [Technical Overview](#technical-overview)
- [Instructions](#instructions)
  - [Create Environment](#create-environment)
  - [Sybase Installation](#sybase-installation)
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
cat sample_response.txt | sed '/SY_CFG_ASE_SAMPLE_DB=false/ s/false/true/' | sed '/SY_CFG_ASE_MASTER_DEV_SIZE=/ s/52/2000/' |  sed '/SY_CFG_ASE_MASTER_DB_SIZE=/ s/26/1000/' > response.txt
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
isql -Usa -SSYBASE -PSybase123 -i ./installpubs2
