res=$(docker image inspect $1:latest --format="exists")
if [ "$res" != "exists" ]; then
    docker build -t $1 /home
fi

# ports
cnrudr=(5400)
cnrudm=(5000 5001 5002 5003 5004 5005)
cnrnrf_vnf=(8001 8006 8007 8010)
cnramf=(6210 6211 6212 6213 6286 6287)
cnrsmf=(6110 6111 6122 6117 6112 6113 6121 6114 6115 6116 6118 6120 2152 6124 6123 6126 6127 6128 6129 6130 6990 6131 6133 6134 6135)
cnrausf=(5500 5501 5502)
cnrnssf=(8000 8001 6286)
cnrupf=(1800 1801 1802 1803 1804 8443)

touch /home/report
apt-get install netcat
if [ "$1" == "cnrudr" ]; then
    id=$(docker run -it -d --privileged=true -p 5400:5400 $1)
    docker exec $id apt-get install -y $1
    sleep 5
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    echo -e $"$1:" >> /home/report
    for port in ${cnrudr[@]}; do
        nc -zv $ip $port >> /home/report 2>&1
    done
    echo -e $"\n"
elif [ "$1" == "cnrudm" ]; then
    id=$(docker run -it -d --privileged=true -p 5000:5000 -p 5001:5001 -p 5002:5002 -p 5003:5003 -p 5004:5004 -p 5005:5005 $1)
    docker exec $id apt-get install -y $1
    sleep 5
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    echo -e $"$1:" >> /home/report
    for port in ${cnrudm[@]}; do
        nc -zv $ip $port >> /home/report 2>&1
    done
    echo -e $"\n"
elif [ "$1" == "cnrnrf-vnf" ]; then
    id=$(docker run -it -d --privileged=true -p 8001:8001 -p 8006:8006 -p 8007:8007 -p 8010:8010 --network nf_net $1)
    docker exec $id apt-get install -y $1
    sleep 5
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    echo -e $"$1:" >> /home/report
    for port in ${cnrnrf_vnf[@]}; do
        nc -zv $ip $port >> /home/report 2>&1
    done
    echo -e $"\n"
elif [ "$1" == "cnramf" ]; then
    id=$(docker run -it -d --privileged=true -p 6210:6210 -p 6211:6211 -p 6212:6212 -p 6213:6213 -p 6286:6286 -p 6287:6287 $1)
    docker exec $id apt-get install -y $1
    sleep 5
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    echo -e $"$1:" >> /home/report
    for port in ${cnramf[@]}; do
        nc -zv $ip $port >> /home/report 2>&1
    done
    echo -e $"\n"
elif [ "$1" == "cnrsmf" ]; then
    id=$(docker run -it -d --privileged=true -p 6110:6110 -p 6111:6111 -p 6122:6122 -p 6117:6117 -p 6112:6112 -p 6113:6113 \
    -p 6121:6121 -p 6114:6114 -p 6115:6115 -p 6116:6116 -p 6118:6118 -p 6120:6120 -p 2152:2152 -p 6124:6124 -p 6123:6123 \
    -p 6126:6126 -p 6127:6127 -p 6128:6128 -p 6129:6129 -p 6130:6130 -p 6990:6990 -p 6131:6131 -p 6133:6133 -p 6134:6134 -p 6135:6135 $1)
    docker exec $id apt-get install -y $1
    sleep 5
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    echo -e $"$1:" >> /home/report
    for port in ${cnrsmf[@]}; do
        nc -zv $ip $port >> /home/report 2>&1
    done
    echo -e $"\n"
elif [ "$1" == "cnrausf" ]; then
    id=$(docker run -it -d --privileged=true -p 5500:5500 -p 5501:5501 -p 5502:5502 $1)
    docker exec $id apt-get install -y $1
    sleep 5
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    echo -e $"$1:" >> /home/report
    for port in ${cnrausf[@]}; do
        nc -zv $ip $port >> /home/report 2>&1
    done
    echo -e $"\n"
elif [ "$1" == "cnrnssf" ]; then
    id=$(docker run -it -d --privileged=true -p 8100:8100 -p 8101:8101 -p 6286:6286 $1)
    docker exec $id apt-get install -y $1
    sleep 5
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    echo -e $"$1:" >> /home/report
    for port in ${cnrnssf[@]}; do
        nc -zv $ip $port >> /home/report 2>&1
    done
    echo -e $"\n"
elif [ "$1" == "cnrupf" ]; then
    id=$(docker run -it -d --privileged=true -p 1800:1800 -p 1801:1801 -p 1802:1802 -p 1803:1803 -p 1804:1804 -p 8443:8443 $1)
    docker exec $id apt-get install -y $1
    sleep 5
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    echo -e $"$1:" >> /home/report
    for port in ${cnrupf[@]}; do
        nc -zv $ip $port >> /home/report 2>&1
    done
    echo -e $"\n"
else
    id=$(docker run -it -d --privileged=true $1)
fi