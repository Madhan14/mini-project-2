pipeline {
  agent any

  environment {
    # Edit these to match your setup, or override in Jenkins job config
    DOCKERHUB_REPO = "madhan14/trend"        // e.g. "<username>/trend"
    EKS_CLUSTER     = "trend-project-eks"    // the EKS cluster name created by Terraform
    AWS_REGION      = "ap-south-1"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker --version'
        // build image tagged with build number
        sh "docker build -t ${env.DOCKERHUB_REPO}:${env.BUILD_NUMBER} ."
      }
    }

    stage('Docker Login & Push') {
      steps {
        // dockerhub-cred is a username/password credential (username=DOCKER_USER, password=DOCKER_PASS)
        withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
          sh "docker push ${env.DOCKERHUB_REPO}:${env.BUILD_NUMBER}"
          // tag latest (optional)
          sh "docker tag ${env.DOCKERHUB_REPO}:${env.BUILD_NUMBER} ${env.DOCKERHUB_REPO}:latest || true"
          sh "docker push ${env.DOCKERHUB_REPO}:latest || true"
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        // Option A: use stored AWS creds (aws-creds). If Jenkins EC2 has an IAM role, you can remove this withCredentials wrapper
        withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh '''
            set -e
            export AWS_REGION=${AWS_REGION}
            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

            # Create kubeconfig for the EKS cluster
            aws eks update-kubeconfig --name ${EKS_CLUSTER} --region ${AWS_REGION}

            # Try to update deployment image; if not present, apply the manifests
            kubectl set image deployment/trend-deployment trend=${DOCKERHUB_REPO}:${BUILD_NUMBER} --record || kubectl apply -f k8s/deployment.yaml

            # Ensure service exists (will create LB)
            kubectl apply -f k8s/service-lb.yaml

            # Wait for rollout
            kubectl rollout status deployment/trend-deployment --timeout=180s

            # Print service info (external DNS)
            echo \"Service info:\"
            kubectl get svc trend-lb -o wide
            kubectl get pods -l app=trend -o wide
          '''
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline finished successfully."
    }
    failure {
      echo "Pipeline failed — check console output."
    }
  }
}
