# Adoptoposs

## Development setup

The app comes with a docker image for development. 
In order to setup the development environment you need to have some dependencies installed on your machine:

- [docker engine](https://docs.docker.com/install/)
- [docker-compose](https://docs.docker.com/compose/install/)
- [git](https://git-scm.com/downloads)
- make (if running on Windows you can use [Cygwin](https://cygwin.com) to install make).

Checkout the Adoptoposs repository with

```
$ git clone git@github.com:paulgoetze/adoptoposs.git
```

Then step into the project and run the setup make task. This will build the docker container, install all dependencies and setup development & test databases:

```
$ cd adoptoposs && make setup
```

Next, start the development server with:

```
$ make up
```

Now you can visit [`localhost:8000`](http://localhost:8000) from your browser.


For further detail on available make tasks please have a look into the task list:

```
$ make usage
```
