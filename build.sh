res=docker image inspect $1:latest --format="exists"
if [ "$res" != "exists" ]; then
    docker build -t $1 --build-arg nf=$1 /home
fi