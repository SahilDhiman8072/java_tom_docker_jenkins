pipeline{
    agent any
    environment{
        image_name="sahild42770/tomcat-deploy"
        artifact_name="vrofile-v2.war"
        bucket_name="java_project"
        ec2A_ip="192.168.14.15"
    }
    stages{
        stage("pull code"){
            steps{
                git branch:'main',url:'https://github.com/SahilDhiman8072/java_tom_docker_jenkins.git'
            }
        }
        stage("buid image"){
            steps{
                sh 'docker build -t $image_name:$BUILD_NUMBER .'
            }
        }
        stage("docker login"){
            steps{
                withCredentials([
                    usernamePassword(
                    credentialsId:"dockerhub",
                    usernameVariable:"dockeruser",
                    passwordVariable: "dockerpass"
                    )
                ]){
                    sh 'echo "$dockerpass" | docker login -u "$dockeruser" --password-stdin'
                }
            }
        }
        stage("push to dockerhub"){
            steps{
                sh 'docker push $image_name:$BUILD_NUMBER'
            }
        }
        stage("run deployment"){
            steps{
                sshagent(['k8s_key']){
                    sh '''
                    ssh -o StrictHostKeyChecking=no \
                    ubuntu@$ec2A_ip \
                    "rm -rf java_tom_docker_jenkins || true"

                    ssh -o StrictHostKeyChecking=no \
                    ubuntu@$ec2A_ip \
                    "git clone https://github.com/SahilDhiman8072/java_tom_docker_jenkins.git"

                    ssh -o StrictHostKeyChecking=no \
                    ubuntu@$ec2A_ip \
                    "cd java_tom_docker_jenkins && kubectl apply -f tomcat-depl -f tomcat-svc -f rabbitmq-depl.yml -f rabbitmq-svc.yml \
                    -f memcache-depl.yml -f mem-svc.yml "

                     ssh -o StrictHostKeyChecking=no ubuntu@$ec2A_ip \
                    "kubectl set image deployment/tomcat-deployment \
                    tomcat-cont=$image_name:$BUILD_NUMBER"
                    
                    '''
                }
            }
        }
    }
}