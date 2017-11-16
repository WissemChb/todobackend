FROM wiss013/todobackend-base:latest
MAINTAINER BEN CHAABEN Wissem <benchaaben.wissem@gmail.com>

#Install dev/build dependencies
RUN yum -y update && \
    yum -y groupinstall 'Development Tools' && \
    yum -y install  python-devel mariadb-devel MySQL-python 


#activate virtual envirement and install wheel support
RUN . /appenv/bin/activate && \ 
    pip install wheel --upgrade

#PIP envirement variables(Note : must be set after installing Wheel)
ENV WHEELHOUSE=/wheelhouse PIP_WHEEL_DIR=/wheelhouse PIP_FIND_LINKS=/wheelhouse XDG_CACHE_HOME=/cache

#OUTPUT : build artifects (wheels) are output here
VOLUME [ "/wheelhouse" ]

#OUTPUT :build  cache
VOLUME [ "/build" ]

#OUTPUT : Test reports are output here
VOLUME [ "/reports" ]

# Add entrypoint test scripts
COPY scripts/test.sh /usr/local/bin/test.sh
RUN chmod +x /usr/local/bin/test.sh

#Set the entrypoint
ENTRYPOINT [ "test.sh" ]
CMD [ "python" ,"manage.py","test","--noinput" ]

#Add application to source
COPY src /application
WORKDIR /application