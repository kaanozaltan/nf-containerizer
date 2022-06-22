res=$(docker image inspect cnrpcf:latest --format="exists")
if [ "$res" != "exists" ]; then
    docker build -t cnrpcf /home
    id=$(docker run -it -d --privileged=true cnrpcf)
    touch /home/out #
    echo "sh arg 1: $1  sh arg 2: $2" > /home/out #
    docker exec $id apt-get install -y cnrpcfcs cnrpcfiws cnrpcfsms cnrpcfams cnrpcfnfrs cnrpcfpes cnrpcfoms #
else
    id=$(docker run -it -d --privileged=true cnrpcf)
    docker exec $id apt-get install -y cnrpcfcs cnrpcfiws cnrpcfsms cnrpcfams cnrpcfnfrs cnrpcfpes cnrpcfoms #
fi