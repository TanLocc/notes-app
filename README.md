
# Notes App with Nodejs and Mysql

Notes App is a Multi Page Application using Nodejs and Mysql. The purpose of this web application is just to be an example for beginners.

![](docs/screenshot2.png)
![](docs/screenshot.png)

## File Structure

- database, it the folder with all the sql queries, you can use to recreate the database for this application
- src, it's all the code for the Backend and Frontend Application
- docs

### Setup the Environment

* You can use a local machine or create a virtual environment by following these steps:
  - Create a virtual machine by EC2 service on AWS
  - Install python 2.7 (need to let cloud9 install the necessary packages when connecting to).
  - Install python 3.7 and nodejs with latest version (need to install packages for microservices).
  - Use cloud9 to connect to the virtual machine just created above to easily deploy and manage microservices.

* Create a virtualenv with Python 3.7 and activate it. Refer to this link for help on specifying the Python version in the virtualenv. 
```bash
python3 -m pip install --user virtualenv
# You should have Python 3.7 available in your host. 
# Check the Python path using `which python3`
# Use a command similar to this one:
python3 -m virtualenv --python=<path-to-Python3.7> .devops
source .devops/bin/activate
```
* Run `make install` to install the necessary dependencies in requirements.txt file
* Install docker
* Install jenkin
* Install kubectl 
* Install AWS cli (If you want to deploy your app on aws)

#### Running on local
mysql -u MYUSR "-pMYPASSWORD"  < ./database/db.sql # create database
npm i
npm run build
npm start

##### Running on eks

*Build eks and node workeworkers
  - aws cloudformation deploy --template-file build-eks.yml --stack-name build-eks --parameter-overrides EKSIAMRoleName=eks-role EKSClusterName=capstone --capabilities CAPABILITY_NAMED_IAM
  - export VPC_ID=$(aws cloudformation describe-stacks --stack-name build-eks --query 'Stacks[0].Outputs[?OutputKey==`VpcId`].OutputValue' --output text)
  - export ClusterControlPlaneSecurityGroup=$(aws cloudformation describe-stacks --stack-name build-eks --query 'Stacks[0].Outputs[?OutputKey==`SecurityGroups`].OutputValue' --output text)
  - export subnets=$(aws cloudformation describe-stacks --stack-name build-eks --query Stacks[0].Outputs[?OutputKey==`SubnetIds`].OutputValue --output text)
  - aws cloudformation deploy  --template-file build-work-node.yml  --stack-name build-work-node --parameter-overrides VpcId=${VPC_ID} ClusterControlPlaneSecurityGroup=${ClusterControlPlaneSecurityGroup} ClusterName=capstone KeyName=micro Subnets=${Subnets} NodeGroupName=groupWorker --capabilities CAPABILITY_NAMED_IAM

*Build anh push imageimage
    docker build .  -t ${DOCKER_IMAGE}:latest
    docker tag ${DOCKER_IMAGE}:latest ${DOCKER_IMAGE}:${dockerTag}
    docker push ${DOCKER_IMAGE}:${dockerTag}
    docker push ${DOCKER_IMAGE}:latest

*Build app on eks
    chmod +x changeTag.sh
    ./changeTag.sh ${dockerTag}
    kubectl apply -f deployk8s
