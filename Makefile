# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= .deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= .config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help



# DOCKER TASKS

# Build the container
generate_docker_compose: ## To generate docker compose for gofish container
	    $(shell ./.generate_docker_compose.sh)

build: generate_docker_compose ## Build the release and development container. The development
	docker-compose build --no-cache $(APP_NAME)
	docker-compose run $(APP_NAME) grunt build
	docker build -t $(APP_NAME) .


run: stop ## Run container on port configured in `config.env`
	docker run -i -t --rm --env-file=./.config.env -p=$(PORT):$(PORT) --name="$(APP_NAME)" $(APP_NAME)


dev: ## Run container in development mode
	docker-compose build --no-cache $(APP_NAME) && docker-compose run $(APP_NAME)

# Build and run the container
up: ## Spin up the project
	docker-compose up --build $(APP_NAME)

stop: ## Stop container
	docker stop $(APP_NAME)

start: ## start  container
	docker start $(APP_NAME)

rm: stop ## Stop and remove running containers
	docker rm $(APP_NAME)

get_logs: ## Get logs about the running container
	docker logs -f $(APP_NAME)

clean: ## Clean the generated/compiles files
	echo "nothing clean ..."
