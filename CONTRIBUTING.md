# Contributing to Adoptoposs

Thanks for considering to contribute to Adoptoposs. ❤

Bug reports, feature suggestions, and pull requests for any open issues are very welcome. Issues can be reported on GitHub: https://github.com/adoptoposs/adoptoposs/issues/new.

Please read and follow our [Code of Conduct](https://github.com/adoptoposs/adoptoposs/blob/main/CODE_OF_CONDUCT.md).

## Development setup

The app comes with a docker image for development. 
In order to setup the development environment you need to have some dependencies installed on your machine:

- make
- [git](https://git-scm.com/downloads)
- [docker engine](https://docs.docker.com/install/)
- [docker-compose](https://docs.docker.com/compose/install/)

Checkout the Adoptoposs repository with

```
$ git clone git@github.com:adoptoposs/adoptoposs.git
```

-----

**For Linux users only:**

> ℹ️ If you are on a Windows or Mac system, you can simply ignore
> this step and move on to the `make setup` step.

On Linux all directories and files that are generated from within the docker
container will be _root-owned_ by default. This will prevent you from editing
files that were created by e.g. the `mix phx.gen` generators in your code editor
without being asked for the root password.
Similarily the _\_build/_, _deps/_, and _assets/node\_modules/_ directories will be root-owned.

In order to prevent this you can set the docker user that should be used in the
container (together with its user id and group id) by using a _.env_ file.

For a default .env file, please copy the content from _.env.sample_ into a `.env` file.

For your convenience you can do this by running:

```bash
cd adoptoposs && make dev-env
```

For further info on the problem and the implemented solution, see
https://jtreminio.com/blog/running-docker-containers-as-current-host-user/.

-----

Next, step into the project directory (if you didn't yet) and run the setup make task.
This will build the docker container, create a development config, install all
dependencies and setup development & test databases:

```
$ cd adoptoposs && make setup
```

Next, start the development server with:

```
$ make up
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


For further detail on available make tasks please have a look into the task list:

```
$ make usage
```

## How to Contribute

For development we use the [git branching model](http://nvie.com/posts/a-successful-git-branching-model) described by [nvie](https://github.com/nvie).

The `develop` branch always represents the current development state.
So, this is the branch you would branch off from when adding your changes.

The `main` branch represents the production state that is deployed to https://adotoposs.org.

Here’s how to contribute:

* Fork it (https://github.com/adoptoposs/adoptoposs/fork)
* Create your feature branch (git checkout -b feature/my-new-feature develop)
* Commit your changes (git commit -am 'Add some feature')
* Push to the branch (git push origin feature/my-new-feature)
* Create a new Pull Request

Try to add tests along with your new feature. This will ensure that your code does not break existing functionality and that your feature is working as expected. You can run the tests with:

```bash
make test
```

To watch file changes and rerun the test suite automatically, you can use:

```bash
make test-watch
```

If you’ve changed any Elixir code, please run Elixir’s code formatter before committing your changes:

```bash
make format
```

This will keep the code style consistent and future code diffs as small as possible.

---------

As a contributor, please keep in mind this project is free and open source software. Maintainers are not paid to work on it, so there might be times were the maintainers seem unresponsive. If you have that feeling, please be patient and be assured, that all team members try their best to review your contribution and reply to you as soon as their time allows.

Once you have submitted your contribution, do not forget to add your name to the [Contributors list](CONTRIBUTORS.md)
