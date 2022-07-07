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

has_settings=(cnramf cnrausf cnrnrf-vnf cnrnssf cnrsmf cnrudm cnrudr cnrnef)
has_profile=(cnrausf cnrnrf-vnf cnrnssf cnrudm cnrudr)
has_automated=(cnrnef cnrnssf cnrnrf-vnf)
all=(NRF AMF AUSF NSSF SMF UDM UDR UPF NEF PCF)
declare -A translate=(["cnrnrf-vnf"]="nrf" ["cnramf"]="amf" ["cnrausf"]="ausf" ["cnrnssf"]="nssf" \
["cnrsmf"]="smf" ["cnrudm"]="udm" ["cnrudr"]="udr" ["cnrupf"]="upf" ["cnrpcfams"]="pcfams" ["cnrpcfcs"]="pcfcs" \
["cnrpcfsms"]="pcfsms" ["cnrpcfnfrs"]="pcfnfrs" ["cnrpcfpes"]="pcfpes" ["cnrpcfoms"]="pcfoms" ["cnrpcfiws"]="pcfiws" ["cnrnef"]="nef")

res=$(docker image inspect $2:latest --format="exists")
if [ "$res" != "exists" ]; then
    docker build -t $2 /build
    apt-get install -y netcat

    cid=$(docker ps -a | grep $2 | awk '{ print $2 }')
    if [ "$cid" != "" ]; then
        docker rm -f $cid
    fi

    var=${translate[$2]}[@]
    for port in ${!var}; do
        ports+="-p $port:$port "
    done

    id=$(docker run -it -d --privileged=true $ports$2)
    docker exec $id apt-get install -y $2 net-tools
    sleep 5

    if [[ "${has_settings[@]}" =~ "$2" ]]; then
        docker cp /build/sto_settings/${2}/settings.json $id:/opt/cinar/${translate[$2]}
    fi
    if [[ "${has_profile[@]}" =~ "$2" ]]; then
        docker cp /build/sto_settings/${2}/NFProfile.json $id:/opt/cinar/${translate[$2]}
    fi
    if [[ "${has_automated[@]}" =~ "$2" ]]; then
        docker cp /build/sto_settings/${2}/settings_automated.json $id:/opt/cinar/${translate[$2]}
    fi

    # pull and run mongo and posgres (only once) and additional tasks
    if [ "$2" == "cnrnrf-vnf" ]; then
        docker pull mongo && docker pull postgres
        mongo_id=$(docker run -it -d -p 27017 --name cinardb mongo)
        postgres_id=$(docker run -e POSTGRES_PASSWORD=1 -d -p 5432:5432 postgres)
        docker exec cinardb sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf.orig
        docker exec cinardb mongo --eval 'db.createUser({user:"cnrusr",pwd:"P5vKG6vE",roles:["userAdminAnyDatabase"]})' admin

        echo -e $"$1 Ön Gerekli Ortam Kurulumu Sonuç Raporu" >> /build/report # create report
    fi

    # add to report
    docker exec $id systemctl restart cnr${translate[$2]}
    ctl=$(docker exec $id systemctl status cnr* | grep 'service -\|Active')
    echo -e $"$2:\n$ctl" >> /build/report
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id)
    for port in ${!var}; do
        nc -zv $ip $port >> /build/report 2>&1
    done
    echo -e $"" >> /build/report

    if [ "$2" == "cnrpcfsms" ]; then
        echo -e $"NRF MongoDB:\n$(docker exec cinardb mongo --eval \
        'db.cinarnfcollection.find({ nfStatus: "REGISTERED" }, { nfType: 1, nfStatus: 1, _id: 0 }).pretty()' stonrfcommon | \
        grep nfType)" >> /build/report

        for nf in ${all[@]}; do
            search_res=$(cat /build/report | grep \"$nf\")
            if [[ "$search_res" == "" && "$nf" != "NRF" ]]; then
                echo -e $"NOT REGISTERED: $nf" >> /build/report
            fi
        done
    fi   
else
    cid=$(docker ps -f status=exited | grep $2 | awk '{ print $2 }')
    if [ "$cid" != "" ]; then
        docker start $cid
    fi
fi