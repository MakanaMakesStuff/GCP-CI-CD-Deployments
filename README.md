# Deployments
Commits to ```main``` will trigger a github workflow that does the following:
1. Checkout code
2. Login to docker
3. Build, tag, and push a docker image to registry
4. SSH into GCP VM
5. Send updated docker-compose.yml and nginx.conf files to VM
6. Logs into docker securely in our VM
7. Pulls in updated docker image from registry
8. Runs docker compose down(to clear old containers) and docker compose up to add new image
9. Runs docker prune to remove unused images
