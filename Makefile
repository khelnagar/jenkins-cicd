### Build + Push Images
.PHONY: build-push
build-push:
	cd ../05-example-web-application/client-react && N=5 $(MAKE) build-N && N=5 $(MAKE) push-N
	cd ../05-example-web-application/api-node && N=9 $(MAKE) build-N && N=9 $(MAKE) push-N
	cd ../05-example-web-application/api-golang && N=8 $(MAKE) build-N && N=8 $(MAKE) push-N
	
### DOCKER SWARM
VM_IP?=192.168.200.168 # efinance
DOCKER_HOST:="ssh://root@${VM_IP}"

.PHONY: swarm-init
swarm-init:
	DOCKER_HOST=${DOCKER_HOST} docker swarm init

.PHONY: swarm-deploy-stack
swarm-deploy-stack:
	DOCKER_HOST=${DOCKER_HOST} docker stack deploy -c docker-compose-swarm.yml example-app --with-registry-auth

.PHONY: swarm-ls
swarm-ls:
	DOCKER_HOST=${DOCKER_HOST} docker service ls

.PHONY: swarm-remove-stack
swarm-remove-stack:
	DOCKER_HOST=${DOCKER_HOST} docker stack rm example-app

.PHONY: create-secrets
create-secrets:
	printf "foobarbaz" | DOCKER_HOST=${DOCKER_HOST} docker secret create postgres-passwd -
	printf "postgres://postgres:foobarbaz@db:5432/postgres" | DOCKER_HOST=${DOCKER_HOST} docker secret create database-url -

.PHONY: delete-secrets
delete-secrets:
	DOCKER_HOST=${DOCKER_HOST} docker secret rm postgres-passwd database-url

.PHONY: redeploy-all
redeploy-all:
	-$(MAKE) swarm-remove-stack
	-$(MAKE) delete-secrets
	@sleep 3
	-$(MAKE) create-secrets
	-$(MAKE) swarm-deploy-stack

### DOCKER COMPOSE COMMANDS

.PHONY: compose-build
compose-build:
	docker compose build

.PHONY: compose-up
compose-up:
	docker compose up

.PHONY: compose-up-build
compose-up-build:
	docker compose up --build

.PHONY: compose-down
compose-down:
	docker compose down

### DOCKER CLI COMMANDS
.PHONY: node-logs
node-logs:
	DOCKER_HOST=${DOCKER_HOST} docker service logs example-app_api-node

.PHONY: node-printenv
node-printenv:
	DOCKER_HOST=${DOCKER_HOST} docker exec c3b0b9a76b3b printenv

DOCKERCONTEXT_DIR:=../05-example-web-application/
DOCKERFILE_DIR:=../06-building-container-images/

.PHONY: docker-build-all
docker-build-all:
	# docker build -t client-react-vite -f ${DOCKERFILE_DIR}/client-react/Dockerfile.3 ${DOCKERCONTEXT_DIR}/client-react/

	docker build -t client-react-ngnix -f ${DOCKERFILE_DIR}/client-react/Dockerfile.5 ${DOCKERCONTEXT_DIR}/client-react/

	docker build -t api-node -f ${DOCKERFILE_DIR}/api-node/Dockerfile.7 ${DOCKERCONTEXT_DIR}/api-node/

	docker build -t api-golang -f ${DOCKERFILE_DIR}/api-golang/Dockerfile.6 ${DOCKERCONTEXT_DIR}/api-golang/

DATABASE_URL:=postgres://postgres:foobarbaz@db:5432/postgres

.PHONY: docker-run-all
docker-run-all:
	echo "$$DOCKER_COMPOSE_NOTE"

	# Stop and remove all running containers to avoid name conflicts
	$(MAKE) docker-stop

	$(MAKE) docker-rm

	docker network create my-network

	docker run -d \
		--name db \
		--network my-network \
		-e POSTGRES_PASSWORD=foobarbaz \
		-v pgdata:/var/lib/postgresql/data \
		-p 5432:5432 \
		--restart unless-stopped \
		postgres:15.1-alpine

	docker run -d \
		--name api-node \
		--network my-network \
		-e DATABASE_URL=${DATABASE_URL} \
		-p 3000:3000 \
		--restart unless-stopped \
		api-node

	docker run -d \
		--name api-golang \
		--network my-network \
		-e DATABASE_URL=${DATABASE_URL} \
		-p 8080:8080 \
		--restart unless-stopped \
		api-golang

	# docker run -d \
	# 	--name client-react-vite \
	# 	--network my-network \
	# 	-v ${PWD}/client-react/vite.config.js:/usr/src/app/vite.config.js \
	# 	-p 5173:5173 \
	# 	--restart unless-stopped \
	# 	client-react-vite

	docker run -d \
		--name client-react-nginx \
		--network my-network \
		-p 80:8080 \
		--restart unless-stopped \
		client-react-ngnix

.PHONY: docker-stop
docker-stop:
	-docker stop db
	-docker stop api-node
	-docker stop api-golang
	-docker stop client-react-vite
	-docker stop client-react-nginx

.PHONY: docker-rm
docker-rm:
	-docker container rm db
	-docker container rm api-node
	-docker container rm api-golang
	-docker container rm client-react-vite
	-docker container rm client-react-nginx
	-docker network rm my-network

define DOCKER_COMPOSE_NOTE

🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨

❯ NOTE:

This command runs the example app with a bunch
of individual docker run commands. This is much
easier to manage with docker-compose (see 
docker-compose.yml and compose make targets above)

🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨


endef
export DOCKER_COMPOSE_NOTE