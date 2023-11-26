# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= .deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))


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

login_info: ## Show default crediantials
	docker logs projet_dill-gophish | grep level #find the container name on docker-compose file

start: ## start the container
	docker start projet_dill-gophish

stop: ## Stop the container
	docker stop projet_dill-gophish

rm:  stop ## Remove the container
	rm docker-compose.yml -fr
	docker rm projet_dill-gophish 

image_clean: clean ## Remove container image
	docker image rm projet_dill-gophish

clean: ## Clean the generated/compiles files
	echo "Clearning docker footprint for network,system and images"
	docker system prune -f
	docker network prune -f
	#docker images prune -f -a