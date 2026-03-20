# need to log into docker using env vars DOCKER_USERNAME and DOCKER_PASSWORD
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# need to build and push the docker image to docker hub
docker build -t $DOCKER_USERNAME/app:latest .
docker push $DOCKER_USERNAME/app:latest

# once we push the image to our registry, we need to ssh into our vm instance and pull the latest image, then restart the container
ssh -o "StrictHostKeyChecking=no" $STAGING_SSH_URL << 'EOF'
  docker pull $DOCKER_USERNAME/app:latest
  docker stop staging-app || true
  docker rm staging-app || true
  docker run -d --name staging-app -p 80:80 $DOCKER_USERNAME/app:latest
EOF