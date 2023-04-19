#!/bin/bash
export FLASK_APP=thing_manager_app
export FLASK_DEBUG=1
export FLASK_RUN_PORT=8080
export FLASK_RUN_HOST=0.0.0.0

export TDD_HOST=http://localhost:9000/
export TS_HOST=http://localhost:7200/
export TS_USER=admin
export TS_PASS=admin
export HELIO=http://localhost:4567/


# pip install -r requirements.txt --force-reinstall