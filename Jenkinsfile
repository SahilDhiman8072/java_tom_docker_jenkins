pipeline{
    agent any
    tools{
        maven 'maven3.9'
        jdk 'jdk21'
    }
    stages{
        stage('pull code'){
            steps{
                git branch:'main', url: 'https://github.com/SahilDhiman8072/java_tom_docker_jenkins.git'
            }
        }
        stage("code test"){
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
                    archiveArtifacts artifacts:'target/*.war'
                }
            }
        }
        stage("checkstyle"){
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }
        stage("sonarqube analyzation"){
            steps{
                script {
        def scannerHome = tool 'sonarqube_tool'

        withSonarQubeEnv('sonarqube') {
            sh """
                ${scannerHome}/bin/sonar-scanner \
                -Dsonar.projectKey=vprofile \
                -Dsonar.projectName=vprofile \
                -Dsonar.sources=src/main/java \
                -Dsonar.java.binaries=target/classes \
                -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml \
                -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
            """
        }
    }
            }
        }
        stage("build tomcat image"){
            steps{
                sh 'docker build -t tomcat_deploy .'
            }
        }
        stage("run tomcat container"){
            steps{
                sh 'docker run -d -p 80:8080 --name tomcat_cont tomcat_deploy'
            }
        }
    }
}