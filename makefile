dc=docker-compose -f docker-compose.yml $(1)
dc-run=$(call dc, run --rm web $(1))
mix-dev=$(call dc-run, mix $(1) MIX_ENV=dev)
mix-test=$(call dc-run, mix $(1) MIX_ENV=test)

usage:
	@echo "Available targets:"
	@echo "  * setup            - Initiate everything (build images, install dependencies, create + migrate db)"
	@echo "  * build            - Build image"
	@echo "  * hex-deps         - Install missing hex dependencies"
	@echo "  * yarn             - Install missing node dependencies"
	@echo "  * db-create        - Create the development database"
	@echo "  * db-migrate       - Migrate the development database"
	@echo "  * setup-test-db    - Setup the test database"
	@echo "  * shell            - Fire up a shell inside of your container"
	@echo "  * iex              - Fire up a iex console inside of your container"
	@echo "  * up               - Run the development server"
	@echo "  * down             - Remove containers and tear down the setup"
	@echo "  * Stop             - Stop the development server"
	@echo "  * test             - Run tests"
	@echo "  * test-watch       - Observe files and run tests on changes"

.PHONY: test


setup: build hex-deps yarn db-create db-migrate setup-test-db

build:
	$(call dc, build)
hex-deps:
	$(call mix-dev, deps.get)
yarn:
	$(call dc, run --rm -w /app/assets/ web yarn)
db-create:
	$(call mix-dev, ecto.create)
db-migrate:
	$(call mix-dev, ecto.migrate)
setup-test-db:
	$(call mix-test, ecto.create)
	$(call mix-test, ecto.migrate)
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

