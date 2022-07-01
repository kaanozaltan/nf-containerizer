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

has_settings=(cnramf cnrausf cnrnrf cnrnssf cnrsmf cnrudm cnrudr)
has_profile=(cnrausf cnrnrf cnrnssf cnrudm cnrudr)
has_automated=(cnrnef cnrnssf cnrnrf)
declare -A translate=(["cnrnrf-vnf"]="nrf" ["cnramf"]="amf" ["cnrausf"]="ausf" ["cnrnssf"]="nssf" \
["cnrsmf"]="smf" ["cnrudm"]="udm" ["cnrudr"]="udr" ["cnrupf"]="upf")

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

    if [[ "${has_settings[@]}" =~ "$1" ]]; then
        docker cp /home/sto_settings/${1}/settings.json $id:/opt/cinar/${translate[$1]}
    fi
    if [[ "${has_profile[@]}" =~ "$1" ]]; then
        docker cp /home/sto_settings/${1}/NFProfile.json $id:/opt/cinar/${translate[$1]}
    fi
    if [[ "${has_automated[@]}" =~ "$1" ]]; then
        docker cp /home/sto_settings/${1}/settings_automated.json $id:/opt/cinar/${translate[$1]}
    fi

    # install mongodb
    #if [ "$1" == "cnrnrf-vnf" ]; then
    #    docker exec $id apt-get install -y wget apt-transport-https
    #    docker exec $id wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
    #    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.4 multiverse" \
    #    | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
    #    docker exec $id apt-get update && apt-get install -y mongodb-org
    #    docker exec $id systemctl enable mongod && systemctl start mongod
    #fi

    # create report
    docker exec $id systemctl restart $1
    ctl=$(docker exec $id systemctl status cnr* | grep 'service -\|Active')
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