pipeline {
    agent
     {
        label "mvn_agent"
    }
    environment {
        PACKAGE_VERSION = "${GIT_BRANCH}-${GIT_COMMIT}"
    }
    parameters {
        choice (
            name: 'DOCKER_BUILD',
            choices: ['no', 'yes'],
            description: 'Shall we build docker image'
        )
        
        choice (
            name: 'DOCKER_PUSH',
            choices: ['nexus', 'cloud'],
            description: 'Shall we build docker image'
        )

        string (
            name: 'DOCKER_TAG',
            defaultValue: 'latest',
            description: 'Tag of docker image'
        )
    }
    tools {
        dockerTool 'docker'
    }

    stages{

        stage("Run tests"){
            steps{
                sh 'mvn test'
            }
        }
        
        stage("Build maven"){
            steps {
                sh 'mvn package \
                -Dmaven.test.skip=true \
                -Dapp=serviceA \
                -Drevision=$PACKAGE_VERSION'
                sh 'ls -la target/'
            }
        }

        stage("Upload jar artifact") {
           when {           
                   branch 'master'
           }            
            steps {
                withCredentials([usernamePassword(credentialsId: 'NEXUS_USER', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                    sh 'ls target '
                    sh '''
                    curl -v \
                        -F maven2.groupId=cicd-demo \
                        -F maven2.asset1.extension=jar \
                        -F maven2.asset1=@target/serviceA-$PACKAGE_VERSION.jar \
                        -F maven2.artifactId=serviceA \
                        -F maven2.version=${GIT_COMMIT} \
                        -u $USERNAME:$PASSWORD http://nexus:8081/service/rest/v1/components?repository=maven-dev
                    '''
                }
            }
        }

       stage("Docker build"){
           when {
               anyOf {
                   branch 'master'
                   expression { params.DOCKER_BUILD == 'yes' }
              }
           }
           environment {
               TAG = "${params.DOCKER_TAG}"
           }
           steps {
                   sh 'ls'
                   echo ''
                   sh 'ls target '
                   echo 'build'
                   sh 'docker build -t service-a:$TAG .'
           }
       }
        
       stage("Docker push nexus"){
           when {
               allOf {
                   expression { params.DOCKER_BUILD == 'yes' }
                   expression { params.DOCKER_PUSH == 'nexus' }
              }
           }
           environment {
               TAG = "${params.DOCKER_TAG}"
           }
           steps {
               withCredentials([usernamePassword(credentialsId: 'NEXUS_USER', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                   sh 'docker tag service-a:$TAG  nexus.docker.internal:5000/repository/demo/service-a:$TAG'
                   sh 'docker login --username $USERNAME --password $PASSWORD http://nexus.docker.internal:5000/repository/demo '
                   sh 'docker push  nexus.docker.internal:5000/repository/demo/service-a:$TAG'
                   sh 'docker rmi  nexus.docker.internal:5000/repository/demo/service-a:$TAG'
               }
           }
       }
       
        stage("Docker push hub.docker.com"){
           when {
               anyOf {
                   expression { params.DOCKER_BUILD == 'yes' }
                   expression { params.DOCKER_PUSH == 'cloud' }
              }
           }
           environment {
               TAG = "${params.DOCKER_TAG}"
           }
           steps {
               withCredentials([usernamePassword(credentialsId: 'HubDockerUser', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                   sh 'docker build -t service-a:$TAG .'
                   sh 'docker tag service-a:$TAG  petercicd/service-a:$TAG'
                   sh 'docker login --username $USERNAME --password $PASSWORD '
                   sh 'docker push  petercicd/service-a:$TAG'
                   sh 'docker rmi  petercicd/service-a:$TAG'
               }
           }
       }

    }
    post{
        always{
            junit 'target/surefire-reports/**/*.xml'
            cleanWs()
        }
    }
}
