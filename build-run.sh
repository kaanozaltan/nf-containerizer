# ports
cnrudr=()
cnrudm=()
cnrnrf=()
cnramf=()
cnrsmf=()
cnrausf=()
cnrnssf=()
cnrupf=()
cnrpcfams=()
cnrpcfcs=()
cnrpcfsms=()
cnrpcfnfrs=()
cnrpcfpes=()
cnrpcfoms=()
cnrpcfiws=()
cnrnef=()

# nfs with settings.json
has_settings(cnramf cnrausf cnrnrf cnrnssf cnrsmf cnrudm cnrudr cnrupf)
declare -A translate=(["cnrnrf-vnf"]="nrf" ["cnramf"]="amf" ["cnrausf"]="ausf" ["cnrnssf"]="nssf" ["cnrsmf"]="smf" ["cnrudm"]="udm" ["cnrudr"]="udr" ["cnrupf"]="upf")

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
    docker exec $id apt-get install -y $1 net-tools
    sleep 5

    if [[ " ${has_settings[*]} " =~ " $1 " ]]; then
        docker cp settings/${1}/settings.json /opt/cinar/${translate[$1]}
    fi

    # create report
    docker exec $id systemctl restart $1
    ctl=$(docker exec $id systemctl status cnr* | grep 'service -\|Active'
    echo -e $"$1:\n$ctl" >> /home/report
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    for port in ${!var}; do
        nc -zv $ip $port >> /home/report 2>&1
    done
    echo -e $"" >> /home/report
else
    cid=$(docker ps -f status=exited | grep $1 | awk '{ print $1 }')
    if [ "$cid" != "" ]; then
        docker start $cid
    fi
fi