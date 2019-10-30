FROM python:3.7.2-alpine

RUN pip3 install tavern

#Move code to container and run
ADD /test /test
WORKDIR /test

EXPOSE 9000

ENTRYPOINT ["py.test", "test_set.tavern.yaml", "-v"]