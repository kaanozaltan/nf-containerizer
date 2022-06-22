res=$(docker image inspect $1:latest --format="exists")
if [ "$res" != "exists" ]; then
    docker build -t $1 /home
    id=$(docker run -it -d --privileged=true $1)
    docker exec $id apt-get install -y $1
else
    id=$(docker run -it -d --privileged=true $1)
    docker exec $id apt-get install -y $1
fi