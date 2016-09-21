FROM centos:centos7

MAINTAINER Johann Bernez

# Add the ASE binaries necessary to install (do not use ADD or docker extract it is a tgz)
COPY /ASE_Suite.linuxamd64.tgz /tmp/ASE_Suite.linuxamd64.tgz

ADD responseFile /tmp/responseFile

# LD_POINTER_GUARD explained at : http://froebe.net/blog/2006/12/11/ase-125x-64bit-and-ase-15-fail-to-start-using-glibc/

RUN cd /tmp && \
	yum -y update && \
	yum -y install glibc.i686 libaio && \
	yum -y clean all && \
	echo "export LD_POINTER_GUARD=0" >> ~/.bash_profile && \
	export LD_POINTER_GUARD=0 && \
	tar -xzf ASE_Suite.linuxamd64.tgz && \
	rm ASE_Suite.linuxamd64.tgz && \
	./ASE_Suite/setup.bin -f /tmp/responseFile -i silent -DAGREE_TO_SAP_LICENSE=true -DRUN_SILENT=true && \
	rm -rf /tmp/* && \
	ln -s /opt/sap/SYBASE.sh /etc/profile.d/sybase.sh && \
    groupadd sybase && \
    useradd -g sybase -s /bin/bash sybase && \
	echo -e "sybase\nsybase" | (passwd sybase) && \
	chown -R sybase:sybase /opt/sap && \
	echo "export SYBASE=/opt/sap" >> ~/.bash_profile

ADD interfaces /tmp/interfaces
