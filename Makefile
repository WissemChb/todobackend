#Project variable
PROJECT_NAME ?= todobackend
ORG_NAME ?= wiss013
REPO_NAME ?= todobackend

#Filenames
DEV_COMPOSE_FILE := docker/dev/docker-compose.yml
REL_COMPOSE_FILE := docker/release/docker-compose.yml

#Docker compose project name
REL_PROJECT := $(PROJECT_NAME)$(BUILD_ID)
DEV_PROJECT := $(REL_PROJECT)dev

# Check and Inspect Logic
INSPECT := $$(docker-compose -p $$1 -f $$2 ps -q $$3 | xargs -I ARGS docker inspect -f "{{ .State.ExitCode }}" ARGS)

CHECK := @bash -c '\
	if [[ $(INSPECT) -ne 0 ]]; \
	then exit $(INPSPECT); fi' VALUE



.PHONY: test build release clean

test: 
	${GLOBALINFO} "Starting testing development envirement"
	${INFO} "Pulling updated image ..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) pull
	${INFO} "Building development image ..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build --pull test
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build  cache
	${INFO} "Ensure database image is connected ..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) run --rm agent
	${INFO} "Starting test image ..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up test
	${INFO} "Copying reports file to client machine ..."
	@ docker cp $$(docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q test):/reports/.  reports
	${CHECK} $(DEV_PROJECT) $(DEV_COMPOSE_FILE) test
	${GLOBALINFO} "Test complete ..."


build:
	${GLOBALINFO} "Starting building application"
	${INFO} "Rebuild development image for the build stage ..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build builder
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up builder
	${CHECK} $(DEV_PROJECT) $(DEV_COMPOSE_FILE) builder
	${INFO} "Copying artifacts to target folder ..."
	@ docker cp $$(docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q builder):/wheelhouse/. target
	${GLOBALINFO} "Build complete"

release:
	${GLOBALINFO} "Starting release application ..."
	${INFO} "Start pulling test image ..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) pull test
	${INFO} "Start Building app and webroot images ..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build app
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build webroot
	${INFO} "Start Building nginx image with pull flag ..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) build --pull nginx
	${INFO} "Ensure database image is connected ..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm agent
	${INFO} "Adding static web files ..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app manage.py collectstatic --noinput
	${INFO} "Creating database model ..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) run --rm app manage.py migrate --noinput
	${INFO} "Runnig Acceptance tests ..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) up test
	${INFO} "Copying reports file to client machine ..."
	@ docker cp $$(docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) ps -q test):/reports/.  reports
	${CHECK} $(REL_PROJECT) $(REL_COMPOSE_FILE) test
	${GLOBALINFO} "Release complete"

clean:
	${GLOBALINFO} "Destroying development envirement ..."
	${INFO} "Clean development images ..."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) kill
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) rm -f -v
	${INFO} "Clean release images..."
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) kill
	@ docker-compose -p $(REL_PROJECT) -f $(REL_COMPOSE_FILE) rm -f -v
	${INFO} "Delete dangling Images ..."
	@ docker images -q -f dangling=true -f label=application=$(REPO_NAME) | xargs -I ARGS docker rmi -f ARGS
	${GLOBALINFO} "Clean complete"

tag:
	${GLOBALINFO} "Tagging release image ..."
	@ docker tag todobackend_app wiss013/todobackend:0.1.0
	${GLOBALINFO} "Tag complete ..."

login:
	${GLOBALINFO} "Login in docker.io ..."
	@ docker login -u wiss013 -p ubuntu12.04 
	${GLOBALINFO} "Login complete ..."

logout:
	${GLOBALINFO} "Logout  ..."
	@ docker logout
	${GLOBALINFO} "Logout complete ..."

publish:
	${GLOBALINFO} "Publishing release Image ..."
	@ docker push wiss013/todobackend:0.1.0
	${GLOBALINFO} "Publishing complete ..."
all: test build release clean

#Cosmetica
YELLOW := "\e[1;33m"
NC := "\e[0m"
GREEN := "\e[0;32m"

# Shell Function
GLOBALINFO := @bash -c '\
	printf $(YELLOW); \
	echo "=> $$1"; \
	printf $(NC)' VALUE
INFO := @bash -c ' \
	printf $(GREEN); \
	echo "=> $$1"; \
	printf $(NC)' VALUE