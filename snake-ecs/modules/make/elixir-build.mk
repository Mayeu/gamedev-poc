# Our app details
APP_NAME ?= $(shell grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')
APP_VSN ?= $(shell grep 'version:' mix.exs | cut -d '"' -f2 )
BUILD ?= $(shell git rev-parse --short HEAD )
MIX_ENV ?= prod

EX_FILE = $(shell find . -name '*.ex')
SLIME_FILE = $(shell find . -name '*.slime')
POT_FILE = $(shell find . -name '*.pot')
PO_FILE = $(shell find . -name '*.po')

node-deps: assets/node_modules
assets/node_modules: assets/package.json assets/yarn.lock deps
	@echo "📦 Install Javascript dependencies"
	${source}
	yarn install --cwd $(shell dirname $@) --frozen-lockfile
	touch $@

deps: mix.exs mix.lock
	@echo "📦 Install Elixir dependencies"
	${source}
	@mix deps.get
	@touch $@

#.PHONY: build
#build: _build
_build: deps $(EX_FILE) $(SLIME_FILE)
	@echo "🔨 Build Project Saturn"
	${source}
	mix compile
	touch $@

# This is only called on demand to avoid having dirty data in the POT & PO
.PHONY: pot
pot: $(POT_FILE)
$(POT_FILE) &: $(EX_FILE)
	${source}
	mix gettext.extract

.PHONY: po
po: $(PO_FILE)
$(PO_FILE) &: $(POT_FILE)
	${source}
	mix gettext.merge priv/gettext

.PHONY: s serve
s: server
serve: server

.DEFAULT_GOAL := serve
## Serve site at http://localhost:3000 with live reloading
.PHONY: server
server: _build uploads
	@echo "🏁 Start the server"
	${source}
	mix phx.server

.PHONY: si
si: server-i

.PHONY: server-i
## ✨ Serve site at http://localhost:3000 with live reloading
## in interactive mode ✨
server-i: _build uploads
	@echo "🏁 Start the server in interactive mode ✨"
	${source}
	iex -S mix phx.server

uploads:
	@echo "📁 Create the required uploads folder"
	${source}
	@mkdir -p $@


.PHONY: test
## Run the tests
test: _build
	@echo "🧪  Run the tests"
	${source}
	PROJECT_SATURN_UPLOAD_DIR=/tmp
	mix test

.PHONY: test-watch t
t: test-watch
## Run the tests on file change
test-watch: _build
	@echo "🧪  Run the tests"
	${source}
	PROJECT_SATURN_UPLOAD_DIR=/tmp
	mix test.watch


## Create a release of the project
RELEASE_ARCHIVE = "_build/$(MIX_ENV)/rel/$(APP_NAME)/releases/$(APP_VSN)/$(APP_NAME).tar.gz"
RELEASE_PATH = "_build/$(MIX_ENV)/rel/$(APP_NAME)/releases/$(APP_VSN)/"

.PHONY: release
release: $(RELEASE_PATH)
$(RELEASE_PATH): rel _build config/config.exs config/runtime.exs config/prod.exs
	@echo "📦 Create a project release"
	MIX_ENV=prod mix release --path $(RELEASE_PATH)
	touch $@

.PHONY: run-release
run-release: $(RELEASE_PATH)
	@echo "🏁 Run Project Saturn"
	${source}
	#_build/prod/rel/project_saturn/bin/project_saturn foreground
	$^/bin/project_saturn start

.PHONY: clean
## Clean all the artifacts: assets/node_modules, deps, _build, etc.
clean:
	@echo "🗑  Delete artifacts"
	@rm -rf deps
	@rm -rf _build
	@rm -rf assets/node_modules

.PHONY: install-deps
## Install dependencies
install-deps: assets/node_modules deps

# Docker Section
# --------------
#
# This is dedicated to target that are docker related

.PHONY: docker-build
## Build the Docker image
TAG = $(APP_VSN)-$(BUILD)
BUILDER_IMG = $(APP_NAME)-builder
TESTER_IMG = $(APP_NAME)-tester

docker-build:
	@echo "🐳 Build the docker image"
	${source}
	docker build \
			--rm=false \
			--build-arg APP_NAME=$(APP_NAME) --build-arg APP_VSN=$(APP_VSN) \
			-t $(BUILDER_IMG):$(TAG)                      \
			-t $(BUILDER_IMG):latest                                   \
			--target builder .

.PHONY: docker-test
docker-test: #docker-build
	@echo "🐳 Test the docker image"
	${source}
	#docker build \
	#    	--build-arg APP_NAME=$(APP_NAME) --build-arg APP_VSN=$(APP_VSN) \
	#		-t $(TESTER_IMG):$(TAG)                       \
	#		-t $(TESTER_IMG):latest                                    \
	#		--target tester .
	docker run -e MIX_ENV=test  $(BUILDER_IMG) make test

.PHONY: docker-release
docker-release:
	@echo "🐳 Create a production docker image"
	${source}
	docker build \
	    	--build-arg APP_NAME=$(APP_NAME) --build-arg APP_VSN=$(APP_VSN) \
			-t $(APP_NAME):$(APP_VSN)-$(BUILD)                              \
			-t $(APP_NAME):latest                                           \
			--target production .

.PHONY: docker-serve
## Run the app in Docker
docker-serve: # docker-release
	@echo "🐳 Run Project Saturn in docker"
	${source}
	docker run                                             \
		-e BASIC_AUTH_USERNAME="$${BASIC_AUTH_USERNAME}"   \
	    -e BASIC_AUTH_PASSWORD="$${BASIC_AUTH_PASSWORD}"   \
		-e REPLACE_HOST_VARS="$${REPLACE_HOST_VARS}"     \
		-e ERLANG_COOKIE="$${ERLANG_COOKIE}" \
	    -e NODE_NAME="$${NODE_NAME}"              \
		-e PORT="$${PORT}" \
		-e URL_PORT="$${URL_PORT}" \
		-e URL_SCHEME="$${URL_SCHEME}" \
		-e URL_HOST="$${URL_HOST}" \
		-e SECRET_KEY_BASE="$${SECRET_KEY_BASE}"\
		-e MAILGUN_BASE_URI="$${MAILGUN_BASE_URI}" \
		-e MAILGUN_API_KEY="$${MAILGUN_API_KEY}" \
		-e MAILGUN_DOMAIN="$${MAILGUN_DOMAIN}" \
		-e PROJECT_SATURN_EMAIL_SITE_NAME="$${PROJECT_SATURN_EMAIL_SITE_NAME}" \
		-e PROJECT_SATURN_EMAIL_FROM_NAME="$${PROJECT_SATURN_EMAIL_FROM_NAME}" \
		-e PROJECT_SATURN_EMAIL_FROM="$${PROJECT_SATURN_EMAIL_FROM}" \
		-e PROJECT_SATURN_UPLOAD_DIR="/opt/app/uploads" \
		-v $${PROJECT_SATURN_UPLOAD_DIR}:/opt/app/uploads \
        --expose $${PORT} -p $${PORT}:$${PORT}        \
        --rm -it $(APP_NAME):latest
