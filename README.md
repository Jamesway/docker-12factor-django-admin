# A 12 Factor django-admin Docker Image (Python 3.6)
Brings package management to Pip.  

## The problem
When building a web app we'd like to employ the 12 factor app approach, so we need to get secrets out of settings.py and ideally into an .env file. Also docker supports .env files so, we're heading in the right direction. [Cookiecutter]() is one way to get this all wired up, but is a little more opinionated than I like. Also, until I personally see the need, for certain tools, I don't add them to my stack.

Where we would like to end up is:
- use docker to start a 12 factor django project
- run the the app with docker/docker-compose
- git pull the src and do a docker pipenv install to get all packages and a working django app
- be deployable to Google App Engine and Heroku


### Starting a Django App
```
docker run --rm -v $(pwd):/code jamesway/12factor-django-admin startproject [project_name]
```

### Install all packages from a Pipfile
```
docker run --rm -v $(pwd):/code jamesway/python36-pipenv install
```

### Installing a package
```
docker run --rm -v $(pwd):/code jamesway/python36-pipenv install [package]

# dev package
docker run --rm -v $(pwd):/code jamesway/python36-pipenv install [package] --dev
```

### runserver
```
docker run --rm -v $(pwd):/code jamesway/python36-pipenv manage.py runserver 0:8000
```
