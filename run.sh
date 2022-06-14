cd /etc/apt/sources.list.d
touch cinar.list
printf "deb [trusted=yes] http://192.168.13.173:8080/repos/thirdparty/ amd64/\n" >> cinar.list
printf "deb [trusted=yes] http://192.168.13.173:8080/repos/cinar/ amd64/\n" >> cinar.list
printf "deb [trusted=yes] http://192.168.13.173:8080/repos/interworking/ amd64/\n" >> cinar.list
printf "deb [trusted=yes] http://192.168.13.173:8080/repos/latest/ amd64/\n" >> cinar.list
cat cinar.list
apt update
apt install -y cnrudm
systemctl restart cnrudm
systemctl status cnrudm
/bin/bash