# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= .deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

CONTAINER_NAME = projet_dill-gophish
LOGIN_INFO_FILE = .default_credentials

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS

# Build the container
generate_docker_compose: ## To generate docker-compose for gofish container
	    @sudo sh .generate_docker_compose.sh

# Build and run the container
up: generate_docker_compose ## Spin up the project
	docker-compose up -d

login_info: ## Show default credentials
	#@if [ -f $(LOGIN_INFO_FILE) ]; then \
	#	cat $(LOGIN_INFO_FILE); \
	#else \
	#	docker inspect --format='{{.State.Running}}' $(CONTAINER_NAME) 2>/dev/null | grep -q 'true' && \
	#	docker logs $(CONTAINER_NAME) | grep level > $(LOGIN_INFO_FILE) || true; \
	#fi
	docker logs $(CONTAINER_NAME) | grep level
default_credentials: login_info
	cat $(LOGIN_INFO_FILE);

start: ## start the container
	docker start $(CONTAINER_NAME) 

stop: ## Stop the container
	docker stop $(CONTAINER_NAME)

rm:  stop ## Remove the container
	rm docker-compose.yml -fr
	docker rm $(CONTAINER_NAME)
	rm -f $(LOGIN_INFO_FILE)

image_clean: clean ## Remove container image
	docker image rm $(CONTAINER_NAME)

clean: rm ## Clean the generated/compiles files
	echo "Clearning docker footprint for network,system and images"
	docker system prune -f
	docker network prune -f
	#docker images prune -f -a
	rm -f $(LOGIN_INFO_FILE)
