FROM ubuntu:16.04
RUN touch /etc/apt/sources.list.d/cinar.list
RUN printf "deb [trusted=yes] http://192.168.13.173:8080/repos/thirdparty/ amd64/\ndeb [trusted=yes] http://192.168.13.173:8080/repos/cinar/ amd64/\ndeb [trusted=yes] http://192.168.13.173:8080/repos/interworking/ amd64/\ndeb [trusted=yes] http://192.168.13.173:8080/repos/latest/ amd64/" >> /etc/apt/sources.list.d/cinar.list
RUN apt update && apt install -y cnrudm