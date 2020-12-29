FROM ubuntu:focal


RUN apt-get update && apt-get upgrade --assume-yes && apt-get install gcc g++ binutils python3 --assume-yes

RUN useradd -u 1000 -s /bin/sh -m compileuser
USER compileuser 

WORKDIR /home/compileuser


COPY entrypoint.sh entrypoint.sh
COPY compiler compiler
COPY create_output.py create_output.py
ENTRYPOINT [ "./entrypoint.sh" ] 

