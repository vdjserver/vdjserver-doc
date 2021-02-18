# VDJServer Documentation

An umbrella repository to bring together documentation for VDJServer and its tools.

We are moving documentation to ReadTheDocs...

```
$ cd docs
$ docker run -v $PWD:/work:z -it airrc/airr-standards bash
$ cd work
$ sphinx-build -b html . ./_build
```

An automated build is configured at [docker hub](https://hub.docker.com/r/vdjserver/doc/)
to generate new docker images when changes are posted to the repository.

Deploying the new documentation can be performed with a `docker pull` to retrieve the
desired image from docker hub. Then insure that vdjserver-web's docker-compose.yml
references the appropriate image and tag.
