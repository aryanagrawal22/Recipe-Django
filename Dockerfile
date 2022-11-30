FROM python:3.9-alpine3.13

# Name the maintainer
LABEL maintainer="aryanagrawal.in"

ENV PYTHONUNBUFFERED 1

# Copy the requirements.txt to a tmp folder in container
COPY ./requirements.txt /tmp/requirements.txt

# Copy the requirements.dev.txt to a tmp folder in container
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy the app in container 
COPY ./app /app

WORKDIR /app

EXPOSE 8000

# By default the dev_environment is FALSE
ARG DEV=false

# Run these commands

    # Make a virtual environment
RUN python -m venv /py && \
    # Upgrade pip
    /py/bin/pip install --upgrade pip && \
    # Install postgres-client
    apk add --update --no-cache postgresql-client && \
    # Install postgresql-dev and musl-dev in tmp-build-deps folder
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    # Install the requirements file
    /py/bin/pip install -r /tmp/requirements.txt && \
    # If it is development environment then install dev requirements file
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    # End if command
    fi && \
    # Remove the tmp folder
    rm -rf /tmp && \
    # Remove the tmp folder with build deps
    apk del .tmp-build-deps && \
    # Add the django user
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user