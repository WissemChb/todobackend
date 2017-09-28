FROM wiss013/todobackend-base:latest
MAINTAINER BEN CHAABEN Wissem <benchaaben.wissem@gmail.com>

#Copy application artifacts
COPY target /wheelhouse

#Install application
RUN . /appenv/bin/activate && \
    pip install --no-index -f /wheelhouse todoBackend && \
    rm -rf /wheelhouse
