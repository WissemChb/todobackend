#!/bin/bash

#Activate virtual envirement
. /appenv/bin/activate

#Download requirement to build cache
pip download -d /build -r requirements_test.txt --no-input

#Install application test requirements
pip install --no-index -f /build -r requirements_test.txt

#Run entrypoint
exec $@
