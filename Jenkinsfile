pipeline {
  agent any
  environment{
        DOCKER_IMAGE = '0352730247/note-app'
        dockerTag = getLatestCommitId()
        devIp = '3.17.4.180'
        k8sFolder = 'note-app-master'
    }
  
  stages {
    stage('Build EKS'){

      steps {
          script{
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentail', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
              sh "aws cloudformation create-stack --stack-name buildeks --template-body build-eks.yaml"
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
              
               sshagent(['server-keypair']) {
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@${devIp} rm -rf ${k8sFolder}"
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@${devIp} mkdir ${k8sFolder}"
                    sh "scp -o StrictHostKeyChecking=no mysql-deployment.yaml note-app-deployment.yaml ubuntu@${devIp}:/home/ubuntu/${k8sFolder}/"

                    script{
                        try {
                            sh "ssh ubuntu@${devIp} kubectl apply -f ${k8sFolder}/"
                        } catch(error) {
                            sh "ssh ubuntu@${devIp} kubectl create -f ${k8sFolder}/"
                        }
                    }
                }
            }
  }
}

}

def getLatestCommitId(){
	def commitId = sh returnStdout: true, script: 'git rev-parse HEAD'
	return commitId
}