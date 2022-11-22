pipeline {
  environment{
        DOCKER_IMAGE = '0352730247/note-app'
        dockerTag = getLatestCommitId()
        devIp = '3.17.4.180'
        k8sFolder = 'note-app-master'
    }
  agent {
    kubernetes {
      label 'jenkins'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
labels:
  component: ci
spec:
  # Use service account that can deploy to all namespaces
  serviceAccountName: jenkins-admin
  containers:
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
  nodeName: ip-10-0-102-46.us-east-2.compute.internal    
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
"""
}
    }
  stages {

    stage('Buid and Push') {
      steps {
        // git 'https://github.com/TanLocc/node-app.git'
        container('docker') {
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