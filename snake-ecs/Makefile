include modules/make/boilerplate.mk
include modules/make/elixir-build.mk

.PHONY: interactive-server is
## Shorthand for interactive-server
is: interactive-server
## Start Athena in interactive mode with:
## - Phoenix running on http://localhost:3000
interactive-server: deps
	@${source}
	iex -S mix phx.server

.PHONY: test
## Run test suite
test: deps
	export ERL_FLAGS=-kernel start_pg true
	mix test --cover

test-ci: deps
	mix test

.PHONY: tc typecheck
tc: typecheck
typecheck:
	mix gradient && mix dialyzer

.PHONY: test-watch
## Run test suite with code watcher
## Use --stale option (https://github.com/lpil/mix-test.watch#running-tests-of-modules-that-changed)
test-watch: deps
	export ERL_FLAGS=-kernel start_pg true
	mix test.watch --stale
