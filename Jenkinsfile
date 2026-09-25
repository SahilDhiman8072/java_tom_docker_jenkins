pipeline{
    agent any
    tools{
        maven 'maven3.9'
        jdk 'jdk21'
    }
    stages{
        stage('pull code'){
            steps{
                git url: 'https://github.com/SahilDhiman8072/java_tom_docker_jenkins.git'
            }
        }
        stage("code test"){
            steps{
                sh 'mvn test'
            }
        }
        stage("build code"){
            step{
                sh 'mvn install -DskipTests'
            }
        }
    }
}