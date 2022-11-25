pipeline {
  agent any
  environment{
        DOCKER_IMAGE = '0352730247/note-app'
        dockerTag = getLatestCommitId()
        devIp = '3.17.4.180'
        k8sFolder = 'deployk8s'
        VPC_ID=''
        security_Group=''
        subnets=''
    }
  
  stages {
    stage('Build EKS'){

      steps {
          script{
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentail', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                sh "aws cloudformation deploy  --template-file build-eks.yml  --stack-name build-eks --parameter-overrides EKSIAMRoleName=eks-role EKSClusterName=capstone --capabilities CAPABILITY_NAMED_IAM"
                VPC_ID=getVpcId()
                security_Group=getSecurityGroups().trim()
                subnets=getSubnets()
                sh "echo ${VPC_ID}"
                sh "echo ${security_Group}"
                sh "echo ${subnets}"
                
                sh(script:"""
                  aws cloudformation deploy  --template-file build-node.yml  --stack-name build-nodes --parameter-overrides VpcId=\'${VPC_ID}\' \
                  ClusterControlPlaneSecurityGroup=\'${security_Group}\' ClusterName=capstone \
                  KeyName=micro Subnets=\'${subnets}\' \
                  NodeGroupName=groupWorker --capabilities CAPABILITY_NAMED_IAM
                """)
                
                sh "aws eks update-kubeconfig --region us-east-1 --name capstone"
                sh "aws configure list"
                sh "kubectl cluster-info"
                sh "kubectl config set-context --current --namespace=default"          
            }
        }  
      }
    }

    stage('Buid and Push') {
      steps {
        // git 'https://github.com/TanLocc/node-app.git'
      
        script{
          sh "docker build . --network=host -t ${DOCKER_IMAGE}:latest"
          // def runCmd = "docker tag ${DOCKER_IMAGE}:latest ${DOCKER_IMAGE}:${dockerTag}"
          // sh "${runCmd}"
          withCredentials([string(credentialsId: 'docker-hub', variable: 'dockerHubPwd')]) {
            sh "docker login -u 0352730247 -p ${dockerHubPwd}"
          }   
          sh "docker tag ${DOCKER_IMAGE}:latest ${DOCKER_IMAGE}:${dockerTag}"
          sh "docker push ${DOCKER_IMAGE}:${dockerTag}"
          sh "docker push ${DOCKER_IMAGE}:latest"
        }
        
      }
    }
    stage('Deploy'){
            steps {

                sh "chmod +x changeTag.sh"
                sh "./changeTag.sh ${dockerTag}"
              
                script{
                  withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentail', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        try {
                            sh "kubectl apply -f ${k8sFolder}/"
                        } catch(error) {
                            sh "kubectl create -f ${k8sFolder}/"
                        }
                  }
                }
            }
  }
}

}

def getVpcId(){
  def VpcId = sh returnStdout: true, script: "aws cloudformation describe-stacks --stack-name build-eks --query 'Stacks[0].Outputs[?OutputKey==`VpcId`].OutputValue' --output text"
	return VpcId
}

def getSecurityGroups(){
  def SecurityGroups = sh returnStdout: true, script: "aws cloudformation describe-stacks --stack-name build-eks --query 'Stacks[0].Outputs[?OutputKey==`SecurityGroups`].OutputValue' --output text"
	return SecurityGroups
}

def getSubnets(){
    def Subnets = sh returnStdout: true, script: "aws cloudformation describe-stacks --stack-name build-eks --query 'Stacks[0].Outputs[?OutputKey==`SubnetIds`].OutputValue' --output text"
	return Subnets
}

def getLatestCommitId(){
	def commitId = sh returnStdout: true, script: 'git rev-parse HEAD'
	return commitId
}