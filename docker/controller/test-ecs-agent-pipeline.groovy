pipeline {
    agent {
        label 'ecs-agent'
    }
    
    stages {
        stage('Test ECS Agent') {
            steps {
                script {
                    echo "=== ECS Agent Test Started ==="
                    echo "Node Name: ${env.NODE_NAME}"
                    echo "Build Number: ${env.BUILD_NUMBER}"
                    echo "Workspace: ${env.WORKSPACE}"
                    
                    // Display system information
                    sh 'echo "=== System Information ==="'
                    sh 'uname -a'
                    sh 'whoami'
                    sh 'pwd'
                    sh 'df -h'
                    sh 'free -m'
                    
                    // Display environment variables
                    sh 'echo "=== Environment Variables ==="'
                    sh 'env | sort'
                    
                    // Test basic commands
                    sh 'echo "=== Testing Basic Commands ==="'
                    sh 'ls -la'
                    sh 'date'
                    
                    // Simulate some work
                    echo "Simulating work for 30 seconds..."
                    sleep 30
                    
                    echo "=== ECS Agent Test Completed Successfully ==="
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline completed on agent: ${env.NODE_NAME}"
        }
        success {
            echo "ECS Agent test passed successfully!"
        }
        failure {
            echo "ECS Agent test failed!"
        }
    }
}
