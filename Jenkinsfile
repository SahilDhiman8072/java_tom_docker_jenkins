pipeline{
    agent any
    environment{
        image_name="sahild42770/tomcat-deploy"
        artifact_name="vrofile-v2.war"
        bucket_name="java_project"
        ec2A_ip="192.168.1.42"
    }
    stages{
        stage("pull code"){
            steps{
                git branch:'main',url:'https://github.com/SahilDhiman8072/java_tom_docker_jenkins.git'
            }
        }
        stage("buid image"){
            steps{
                sh 'docker build -t $image_name:$BUILD_NUMBER'
            }
        }
        stage("docker login"){
            steps{
                withCredentials([
                    usernamePassword(
                    credentialsId:"",
                    usernameVariable:'dockeruser'
                    passwordVariable:'dockerpass'
                    )
                ]){
                    sh 'echo "$docker_pass" | docker login -u "$docker_user" --password-stdin'
                }
            }
        }
        stage("push to dockerhub"){
            steps{
                sh 'docker push $image_name:$BUILD_NUMBER'
            }
        }
        stage("send artifacts to s3"){
            steps{
                sh '''
                echo "running temp container"
                docker run -d -p 80:8080 --name tomcat_cont $image_name:$BUILD_NUMBER

                docker cp tomcat_cont:/app/target/*.war .

                aws s3 cp $artifact_name s3://$bucket_name
                '''
            }
            post{
                success{
                   sh 'aws s3 ls $bucket_name'
                }
            }
        }
        stage("run deployment"){
            steps{
                sshagent(['ec2A']){
                    sh '''
                    ssh -o StrictHostKeyChecking=no \
                    ubuntu@$ec2A_ip \
                    "rm -rf java_tom_docker_jenkins || true"

                    ssh -o StrictHostKeyChecking=no \
                    ubuntu@$ec2A_ip \
                    "git clone https://github.com/SahilDhiman8072/java_tom_docker_jenkins.git"

                    ssh -o StrictHostKeyChecking=no \
                    ubuntu@$ec2A_ip \
                    "cd java_tom_docker_jenkins && kubectl delete -f tomcat-depl -f tomcat-svc || true"

                    ssh -o StrictHostKeyChecking=no \
                    ubuntu@$ec2A_ip \
                    "cd java_tom_docker_jenkins && kubectl apply -f tomcat-depl -f tomcat-svc"
                    
                    '''
                }
            }
        }
    }
}