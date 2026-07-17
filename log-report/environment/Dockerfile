FROM python:3.11-slim@sha256:e1c5188185fe06038479e09968417c8cf15d6545b7367c3395952d7e5d8b671a

RUN pip install --no-cache-dir pytest==8.4.1 pytest-json-ctrf==0.3.5

WORKDIR /app

COPY access.log /app/access.log