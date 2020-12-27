[Duga](https://github.com/Zomis/Duga) is a robot that performs some tasks in some chat rooms on the Stack Exchange network.  This is a very simple project that simply builds that software inside a software *container* of the kind that [Docker](https://www.docker.com/) or [Podman](https://podman.io/) create and can use.

## Prerequisites
### Using Podman
Podman is a daemonless container engine and can easily be used instead of docker.  Because it does not require any special privileges, this project uses Podman, but the syntax of the Podman commands is essentially identical to Docker's so either can be used.

### Using Docker
Because it is well documented elsewhere, this document will not describe the process for installing and running Docker.  
To test if docker is running we can use

    sudo docker info

On Fedora and similar, the configuration file is `/usr/lib/systemd/system/docker.service`.

## Building Duga in a container image
The simplest way to build a container directly using Podman is start with an empty folder.  Create a `duga.groovy` file in it.  You can start with [Duga's sample](https://github.com/Zomis/Duga/blob/develop/src/main/resources/duga_example.groovy) and customize for your settings.  Then put the [Dockerfile](https://github.com/beroset/Duga_container/blob/main/Dockerfile) from this project into that same directory.  Navigate to that directory and execute this command:

    podman build . -t beroset/duga

This build mechanism requires a recent version of Podman (or Docker) to support [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) and an internet connection.  This starts with a Debian software container, adds required build software and then downloads the `Duga` source code. With the magic of multistage build, we can then create a new, minimal container with [Apache Tomcat](http://tomcat.apache.org/) and the freshly built `Duga` software.  This is why little effort has been expended on making the build image small, since it is essentially thrown away once the required executable has been created.

If everything goes successfully, the result will be a `beroset/duga` container image.  Running `podman images` should verify that the `beroset/duga` image has indeed been created.

## Running Duga in a container image
If you followed the steps above, you can run the software very simply:

    podman run -p 8000:8080 -d beroset/duga

The (local) web interface is mapped to port 8000 on the host computer, but the interface there is not completely implemented.  If everything has been successfully launched, about thirty to sixty seconds later, `Duga` should post a greeting message to [Duga's Neighborhood](https://chat.stackexchange.com/rooms/20298/dugas-neighborhood).

## Image size
The build image is around 1.5GB, but the version that contains `Duga` is only about 398MB.  A modified version of this has been successfully deployed and run on a [Raspberry Pi 4](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/) with 4GB of RAM, but it ran rather slowly and used a lot of CPU cycles.

## A word on Duga customization
I found a few things that may help the next person who tries this.  First, many of the settings within the software are partially hard-coded (such as which chat rooms the robot participates in).  Second, it appears `botName` in `duga.groovy` must be set to `Duga`.  Second, the `rootURL` only worked for me when it was set to `https://codereview.stackexchange.com`. Third, the `commandPrefix` should probably be set to either `@Duga do ` or the name of the user running the robot (e.g. `@Lurch do `).  

Lastly, for simplicity, I elected to use the in-memory [H2 database](https://h2database.com/html/main.html).  This then requires no external database, but it also means the database is lost whenever the container is shutdown or restarted. 
