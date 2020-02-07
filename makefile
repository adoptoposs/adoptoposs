dc=docker-compose -f docker-compose.yml $(1)
dc-run=$(call dc, run --rm web $(1))
mix-dev=$(call dc-run, mix do $(1) MIX_ENV=dev)
mix-test=$(call dc-run, mix do $(1) MIX_ENV=test)
comma:= ,

usage:
	@echo "Available targets:"
	@echo "  * setup            - Initiate everything (build images, install dependencies, create + migrate db)"
	@echo "  * dev-config       - Copy dev config from config/dev.exs.sample"
	@echo "  * build            - Build image"
	@echo "  * hex-deps         - Install missing hex dependencies"
	@echo "  * yarn             - Install missing node dependencies"
	@echo "  * db-setup         - Create & migrate the development database"
	@echo "  * db-migrate       - Migrate the development database"
	@echo "  * db-setup-test    - Create & migrate the test database"
	@echo "  * shell            - Fire up a shell inside of your container"
	@echo "  * iex              - Fire up a iex console inside of your container"
	@echo "  * up               - Run the development server"
	@echo "  * down             - Remove containers and tear down the setup"
	@echo "  * stop             - Stop the development server"
	@echo "  * test             - Run tests"
	@echo "  * test-watch       - Observe files and run tests on changes"

.PHONY: test


setup: dev-config build hex-deps yarn db-setup db-setup-test

dev-config:
	cp -u config/dev.exs.sample config/dev.exs
build:
	$(call dc, build)
hex-deps:
	$(call mix-dev, deps.get)
yarn:
	$(call dc, run --rm -w /app/assets/ web yarn)
db-setup:
	$(call mix-dev, ecto.setup)
db-migrate:
	$(call mix-dev, ecto.migrate)
db-setup-test:
	$(call mix-test, ecto.setup)
shell:
	$(call dc-run, ash)
iex:
	$(call dc-run, iex -S mix)
up:
	$(call dc, up)
down:
	$(call dc, down)
stop:
	$(call dc, stop)
test:
	$(call dc-run, mix test)
test-watch:
	$(call dc-run, mix test.watch)

