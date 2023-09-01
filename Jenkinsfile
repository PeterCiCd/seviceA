pipeline {
    agent {
        label "mvn_agent"
    }

    options {
        ansiColor('xterm')
    }
    
    tools{
        maven 'M3'
        dockerTool 'docker'        
    }
    
    environment {
        PACKAGE_VERSION = "dev"
    }
    
    parameters {
        choice (
            name: 'DOCKER_BUILD',
            choices: ['no', 'yes'],
            description: 'Shall we build docker image'
        )

        string (
            name: 'DOCKER_TAG',
            defaultValue: 'latest',
            description: 'Tag of docker image'
        )
    }
    
    stages {
        stage('SCM') {
            steps {
                // Get some code from a GitHub repository
                git branch: 'senior', url: 'https://github.com/PeterCiCd/seviceA.git'
            }
        }
        stage('Build') {
            steps {

                // Run Maven on a Unix agent.
                sh 'mvn   -Dmaven.test.skip=true \
                            -Dapp=serviceA \
                            -Drevision=$PACKAGE_VERSION \
                            clean package'

            }
        }
        stage('Test') {
            steps {

                // Run Maven on a Unix agent.
                sh "mvn test"

            }
        }
        stage("Upload jar artifact") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'NEXUS_USER', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                    sh 'ls target '
                    sh '''
                    curl -v \
                        -F maven2.groupId=cicd-demo \
                        -F maven2.asset1.extension=jar \
                        -F maven2.asset1=@target/serviceA-$PACKAGE_VERSION.jar \
                        -F maven2.artifactId=serviceA \
                        -F maven2.version=$PACKAGE_VERSION \
                        -u $USERNAME:$PASSWORD $NEXUS_MAVN_URL/service/rest/v1/components?repository=maven-dev
                    '''
                }
            }
        }
        stage("Docker build and push"){
           when {
               anyOf {
                   branch 'senior'
                   expression { params.DOCKER_BUILD == 'yes' }
              }
           }
           environment {
               TAG = "${params.DOCKER_TAG}"
           }
           steps {
               withCredentials([usernamePassword(credentialsId: 'NEXUS_USER', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
                   sh 'docker build -t $NEXUS_DOCKER_IP_PORT/repository/demo/service-a:$TAG .'
                //   sh 'docker tag service-a:$TAG  $NEXUS_DOCKER_IP_PORT/repository/demo/service-a:$TAG'
                   sh 'docker login --username $USERNAME --password $PASSWORD http://$NEXUS_DOCKER_IP_PORT/repository/demo '
                   sh 'docker push  $NEXUS_DOCKER_IP_PORT/repository/demo/service-a:$TAG'
                   sh 'docker rmi  $NEXUS_DOCKER_IP_PORT/repository/demo/service-a:$TAG'
               }
           }
       }
    }
    
    post {
        // If Maven was able to run the tests, even if some of the test
        // failed, record the test results and archive the jar file.
        always {
            junit '**/target/surefire-reports/*.xml'
            archiveArtifacts 'target/*.jar'            
            cleanWs()
        }
    }
        
}
