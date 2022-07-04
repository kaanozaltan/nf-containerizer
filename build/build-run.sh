# ports
udr=()
udm=()
nrf=()
amf=()
smf=()
ausf=()
nssf=()
upf=()
pcfams=()
pcfcs=()
pcfsms=()
pcfnfrs=()
pcfpes=()
pcfoms=()
pcfiws=()
nef=()

has_settings=(cnramf cnrausf cnrnrf-vnf cnrnssf cnrsmf cnrudm cnrudr)
has_profile=(cnrausf cnrnrf-vnf cnrnssf cnrudm cnrudr)
has_automated=(cnrnef cnrnssf cnrnrf-vnf)
declare -A translate=(["cnrnrf-vnf"]="nrf" ["cnramf"]="amf" ["cnrausf"]="ausf" ["cnrnssf"]="nssf" \
["cnrsmf"]="smf" ["cnrudm"]="udm" ["cnrudr"]="udr" ["cnrupf"]="upf" ["cnrpcfams"]="pcfams" ["cnrpcfcs"]="pcfcs" \
["cnrpcfsms"]="pcfsms" ["cnrpcfnfrs"]="pcfnfrs" ["cnrpcfpes"]="pcfpes" ["cnrpcfoms"]="pcfoms" ["cnrpcfiws"]="pcfiws" ["cnrnef"]="nef")

res=$(docker image inspect $1:latest --format="exists")
if [ "$res" != "exists" ]; then
    docker build -t $1 /build
    apt-get install -y netcat

    cid=$(docker ps -a | grep $1 | awk '{ print $1 }')
    if [ "$cid" != "" ]; then
        docker rm -f $cid
    fi

    var=${translate[$1]}[@]
    for port in ${!var}; do
        ports+="-p $port:$port "
    done

    id=$(docker run -it -d --privileged=true $ports$1)
    if [ "$1" == "cnrnrf-vnf" ]; then
        nrf_id=$id
    fi
    docker exec $id apt-get install -y $1 net-tools
    sleep 5

    if [[ "${has_settings[@]}" =~ "$1" ]]; then
        docker cp /build/sto_settings/${1}/settings.json $id:/opt/cinar/${translate[$1]}
    fi
    if [[ "${has_profile[@]}" =~ "$1" ]]; then
        docker cp /build/sto_settings/${1}/NFProfile.json $id:/opt/cinar/${translate[$1]}
    fi
    if [[ "${has_automated[@]}" =~ "$1" ]]; then
        docker cp /build/sto_settings/${1}/settings_automated.json $id:/opt/cinar/${translate[$1]}
    fi

    # pull and run mongo and posgres (only once)
    if [ "$1" == "cnrnrf-vnf" ]; then
        docker pull mongo && docker pull postgres
        mongo_id=$(docker run -it -d -p 27017 mongo)
        postgres_id=$(docker run -e POSTGRES_PASSWORD=1 -d -p 5432:5432 postgres)
    fi

    # create db and user in mongo

    # create report
    docker exec $id systemctl restart cnr${translate[$1]}
    touch /build/report
    ctl=$(docker exec $id systemctl status cnr* | grep 'service -\|Active')
    echo -e $"$1:\n$ctl" >> /build/report
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    for port in ${!var}; do
        nc -zv $ip $port >> /build/report 2>&1
    done
    echo -e $"" >> /build/report
else
    cid=$(docker ps -f status=exited | grep $1 | awk '{ print $1 }')
    if [ "$cid" != "" ]; then
        docker start $cid
    fi
fi