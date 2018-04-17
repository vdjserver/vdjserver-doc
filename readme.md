# VDJServer Documentation

An umbrella repository to bring together documentation for VDJServer and its tools.

An automated build is configured at [docker hub](https://hub.docker.com/r/vdjserver/doc/)
to generate new docker images when changes are posted to the repository.

Deploying the new documentation can be performed with a `docker pull` to retrieve the
desired image from docker hub. Then insure that vdjserver-web's docker-compose.yml
references the appropriate image and tag.
