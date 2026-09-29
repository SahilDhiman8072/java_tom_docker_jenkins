pipeline{
    agent any
    tools{
        jdk 'jdk21'
        maven 'maven3.9'

    }
    environment{
        image_name="sahild42770/tomcat-deploy"
        artifact_name="vprofile-v2.war"
        bucket_name="java-project-artifacts-store-vprofile"
        ec2A_ip="192.168.1.36"
        ec2B_ip="192.168.1.53"
    }
    stages{
        stage("pull code"){
            steps{
                git branch:'main',url:'https://github.com/SahilDhiman8072/java_tom_docker_jenkins.git'
            }
        }
        stage("test code"){
            steps{
                sh 'mvn test'
            }
        }
        stage("build code"){
            steps{
                sh 'mvn install -DskipTests'
            }
            post{
                success{
                    archiveArtifacts artifacts: "target/*.war"
                }
            }
        }
        stage("checkstyle"){
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }
        
        stage("buid image"){
            steps{
                sh 'docker build -t $image_name:$BUILD_NUMBER .'
            }
            post{
                success{
                    sh 'docker images'
                }
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
        stage("push artifacts to s3 bucket"){
            steps{
                sh 'mv target/$artifact_name target/vprofile-v2-${BUILD_NUMBER}.war'
                sh 'aws s3 cp target/vprofile-v2-${BUILD_NUMBER}.war s3://$bucket_name'
            }
            post{
                success{
                    sh 'aws s3 ls s3://$bucket_name'
                }
            }
        }
        stage('SonarQube Analysis') {

    steps {

        script {

            // Step 1: Find SonarScanner installed in Jenkins
            def scannerHome = tool 'sonarqube'

            // Step 2: Connect Jenkins with SonarQube
            withSonarQubeEnv('sonarqube') {

                // Step 3: Run SonarScanner
                sh """
                    ${scannerHome}/bin/sonar-scanner \
                    -Dsonar.projectKey=vprofile \
                    -Dsonar.projectName=vprofile \
                    -Dsonar.sources=src/main/java \
                    -Dsonar.java.binaries=target/classes \
                    -Dsonar.java.source=17 \
                    -Dsonar.checkstyle.reportPaths=target/checkstyle-result.xml \
                    -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                """
            }
        }
    }
}

        stage("run deployment ec2A"){
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
                    "cd java_tom_docker_jenkins && kubectl apply -f  tomcat-deployment.yml -f tomcat-service.yml -f rabbitmq.yml -f rabbimq-svc.yml -f memcache-depl.yml -f mem-svc.yml "

                     ssh -o StrictHostKeyChecking=no ubuntu@$ec2A_ip \
                    "kubectl set image deployment/tomcat-deployment \
                    tomcat-cont=$image_name:$BUILD_NUMBER"
                    
                    '''
                }
            }
        }
        stage("run deployment ec2B"){
            steps{
                sshagent(['ec2A']){
                    sh '''
                    ssh -o StrictHostKeyChecking=no \
                    ubuntu@$ec2B_ip \
                    "rm -rf java_tom_docker_jenkins || true"

                    ssh -o StrictHostKeyChecking=no \
                    ubuntu@$ec2B_ip \
                    "git clone https://github.com/SahilDhiman8072/java_tom_docker_jenkins.git"

                    ssh -o StrictHostKeyChecking=no \
                    ubuntu@$ec2B_ip \
                    "cd java_tom_docker_jenkins && kubectl apply -f  tomcat-deployment.yml -f tomcat-service.yml -f rabbitmq.yml -f rabbimq-svc.yml -f memcache-depl.yml -f mem-svc.yml "

                     ssh -o StrictHostKeyChecking=no ubuntu@$ec2B_ip \
                    "kubectl set image deployment/tomcat-deployment \
                    tomcat-cont=$image_name:$BUILD_NUMBER"
                    
                    '''
                }
            }
        }
    }
    post{
        success{
              slackSend(
                channel: "#all-javavprofileproject",
                color:'good',
                message: """ build successful

                job: ${env.JOB_NAME}
                build_id: ${env.BUILD_ID}
                build number: ${BUILD_NUMBER}
                build url: ${env.BUILD_URL}
                build branch: ${env.BUILD_BRANCH}
                """
              )
        }
        failure{
            slackSend(
                channel: '#all-javavprofileproject',
                color:'danger',
                message:""" build failure

                job: ${env.JOB_NAME}
                build_id: ${env.BUILD_ID}
                build number: ${BUILD_NUMBER}
                build url: ${env.BUILD_URL}
                build branch: ${env.BUILD_BRANCH}
                """
                
            )
        }
    }
}