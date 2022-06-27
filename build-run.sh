# ports
cnrudr=(5400)
cnrudm=(5000 5001 5002 5003 5004 5005)
cnrnrf=(8001 8006 8007 8010)
cnramf=(6210 6211 6212 6213 6286 6287)
cnrsmf=(6110 6111 6122 6117 6112 6113 6121 6114 6115 6116 6118 6120 2152 6124 6123 6126 6127 6128 6129 6130 6990 6131 6133 6134 6135)
cnrausf=(5500 5501 5502)
cnrnssf=(8100 8101) # 6286
cnrupf=(1800 1801 1802 1803 1804 8443)
cnrpcfams=(7000)
cnrpcfcs=(7050 7500)
cnrpcfsms=(7002)
cnrpcfnfrs=(7080)
cnrpcfpes=(7008)
cnrpcfoms=(7052)
cnrpcfiws=(7020)
cnrnef=()

res=$(docker image inspect $1:latest --format="exists")
if [ "$res" != "exists" ]; then
    docker build -t $1 /home
    touch /home/report
    apt-get install -y netcat

    cid=$(docker ps -a | grep $1 | awk '{ print $1 }')
    if [ "$cid" != "" ]; then
        docker rm -f $cid
    fi

    ports=""
    if [ "$1" == "cnrnrf-vnf" ]; then
        var=cnrnrf[@]
    else
        var=$1[@]
    fi
    for port in ${!var}; do
        ports+="-p $port:$port "
    done

    id=$(docker run -it -d --privileged=true $ports$1)
    docker exec $id apt-get install -y $1
    sleep 5
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    echo -e $"$1:" >> /home/report
    for port in ${!var}; do
        nc -zv $ip $port >> /home/report 2>&1
    done
    echo -e $"" >> /home/report
else
    cid=$(docker ps --filter status=paused | grep $1 | awk '{ print $1 }')
    if [ "$cid" != "" ]; then
        docker start $cid
    fi
fi