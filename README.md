# SAP Adaptive Server Enterprise (formerly SAP Sybase ASE) running on Docker

For one of a recent mission, I had to use a "Sybase" database. As I am know familiar with Docker, I though it could be interesting to run the database in its own container. Thus we would be able to scratch the instance at any time, especially for testing purpose, schema evolution and replication.

## Prerequisites
Before creating the container(s), you have to obtain the binaries of the SAP Adaptive Server. This is probably the most difficult part of the process. At a given time, there was a developer edition. Now, you have to download the SAP Adaptive Server Enterprise edition. The developer edition has been by a special license that you have to choose at the installation time.

To download it, you have to register for a *free* version by using this [registration form](
https://go.sap.com/cmp/syb/crm-xu15-int-asewindm/index.html?url_id=text-us-sapcom-ase-trial-software).
Alternatively, you can try to download directly the binaries for [Linux](http://d1cuw2q49dpd0p.cloudfront.net/ASE16.0/Linux16SP02/ASE_Suite.linuxamd64.tgz) or [Windows](http://d1cuw2q49dpd0p.cloudfront.net/ASE16.0/Windows16SP02/ASE_Suite.winx64.zip) (if the links are still working). The linux version is required ad Docker runs linux.

This project assumes that you already have docker installed on your computer, up and running.

## Docker images
This project is composed of two folders.

The first one, *data*, is simply for defining the image that will be used to store the data of the SAP Adaptive Server. See this [docker documentation](https://docs.docker.com/engine/tutorials/dockervolumes/) for more information.

The second one, *server*, is the image that will contain the SAP Adaptive Server, configure it, start the instance and also initialize an empty database.

To build the first image, go in the *data* folder and issue the following command in a terminal:
```
# Build the image for the data container
docker build -t sybase/data:latest .
```

To build the second image, go in the *server* folder and issue the following command in a terminal:
```
# Build the image for the server container
docker build -t sybase/server:latest .
```

## Docker containers
To create the data container, issue the following command (becareful to the path that is made for a windows version, you may have to change it):
```
# Create the data container, mount a volume from host machine to container
# Becareful, the path must starts with "//c/Users/your_user/..." otherwise the volume won't work, because dockers's virtual box only share your home folder...
docker create --name sybase-data -v //c/Users/naaooj/volumes/sybase/data:/tmp/data sybase/data:latest /bin/true
```

To run the server container, issue the following command:
```
# Create and start the sybase server interactively, the creation process of the database is displayed in the output
docker run -it --hostname=ASE -p 5000:5000 --privileged=true --volumes-from sybase-data --name=sybase-server sybase/server:latest bash
```

## How it works
The first image is really simple and does not require any explanation. The second one is more complicated and performs a lot more operations. Described below the most important operations.

### LD_POINTER_GUARD
```
echo "export LD_POINTER_GUARD=0" >> ~/.bash_profile
export LD_POINTER_GUARD=0
```
Due to the version of centos and glibc, the environment variable LD_POINTER_GUARD must be set to **0** otherwise Adaptive Server binaries will not work and throw a segmentation fault. It is added in the profile and is going to be used when a container is created, and it is also added in the current execution in order to install Adaptive Server with no error.

### Setup
```
./ASE_Suite/setup.bin -f /tmp/responseFile -i silent -DAGREE_TO_SAP_LICENSE=true -DRUN_SILENT=true
```
Adaptive server can be installed silently using a response file. Using this type of setup with docker is very easy. To get the response file, I had no other choise than running the setup in a centos VM (in console or in GUI), passing the *-r response_file* option to the setup. This is well explained in this [book](http://help.sap.com/Download/Multimedia/zip-ase1602/SAP_ASE_Installation_Guide_Linux_en.pdf), chapter 6.3.1 on page 45.

### Groups and permission
```
groupadd sybase
useradd -g sybase -s /bin/bash sybase
echo -e "sybase\nsybase" | (passwd sybase)
chown -R sybase:sybase /opt/sap
```
Adaptive server requires a dedicated user and group to run, named *sybase*. These commands declare a *sybase* user, having *sybase* as password, under the *sybase* group.
