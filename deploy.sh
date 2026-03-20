DEPLOY_TAG=$1
DEPLOY_TYPE=$2

DEPLOY_TYPE=${DEPLOY_TYPE:-staging}

if [ "${DEPLOY_TYPE}" != "staging" ] && [ "${DEPLOY_TYPE}" != "production" ]; then
  echo "Error: Invalid deploy type passed. Usage: npm run deploy <deploy-tag> 'staging'|'production'"
  exit 1
fi

# load env file
ENV_FILE=".env.${DEPLOY_TYPE}"
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE file not found!"
  exit 1
fi

echo "Loading environment vars from file"
set -a
source "$ENV_FILE"
set +a

# check if required env vars are set
REQUIRED_VARS=(DOCKER_PASSWORD DOCKER_USERNAME GCP_VM_SSH_URL)
for VAR in "${REQUIRED_VARS[@]}"
  do
    if [ -z "${!VAR}" ]; then
      echo "Error: $VAR environment variable is not set!"
      exit 1
    fi
  done

echo "All required env vars are set."

if [ -z "${DEPLOY_TAG}" ]; then
  echo "Error: No deploy tag was provided. Usage: npm run deploy <deploy-tag>"
  exit 1
fi

echo "Checking if deploy tag already exists in registry..."

if docker manifest inspect "$DOCKER_USERNAME/${DEPLOY_TYPE}:$DEPLOY_TAG" > /dev/null 2>&1; then
  echo "Error: Tag '$DEPLOY_TAG' already exists in the registry. Please update the tag and try again."
  exit 1
fi

echo "Starting deployment process for tag: $DEPLOY_TAG."

# need to log into docker using env vars DOCKER_USERNAME and DOCKER_PASSWORD
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# need to build and push the docker image to docker hub
docker build -t $DOCKER_USERNAME/$DEPLOY_TYPE:$DEPLOY_TAG .
docker push $DOCKER_USERNAME/$DEPLOY_TYPE:$DEPLOY_TAG

# once we push the image to our registry, we need to ssh into our vm instance and pull the latest image, then restart the container
ssh -o "StrictHostKeyChecking=no" $GCP_VM_SSH_URL << EOF
  docker pull $DOCKER_USERNAME/$DEPLOY_TYPE:$DEPLOY_TAG
  docker stop $DEPLOY_TYPE || true
  docker rm $DEPLOY_TYPE || true
  docker run -d --name $DEPLOY_TYPE -p 80:3000 $DOCKER_USERNAME/$DEPLOY_TYPE:$DEPLOY_TAG
  docker image prune -f
EOF