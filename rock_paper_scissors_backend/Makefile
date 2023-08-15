.DEFAULT_GOAL := help

help:
	@echo "Targets:"
	@echo "- docker-build: Build docker image"
	@echo "- docker-run: Run docker image"
	@echo "- docker-push-gcp: Push docker image to GCP"

docker-build:
	docker build --platform=linux/amd64 -t tp-bcc361 .

docker-run:
	docker run -p 3000:3000 tp-bcc361

docker-push-gcp:
	@echo "Pushing to GCP"
	docker tag tp-bcc361 southamerica-east1-docker.pkg.dev/tp-bcc361/rock-paper-scissor/tp-bcc361
	docker push southamerica-east1-docker.pkg.dev/tp-bcc361/rock-paper-scissor/tp-bcc361
