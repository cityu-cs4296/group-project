#!/bin/bash

# docker init and installation
# sudo yum update
# sudo yum -y install docker
# sudo service docker start
# sudo usermod -a -G docker ec2-user
# sudo chkconfig docker on
# pip3 install docker-compose

# sudo docker swarm init --advertise-addr <address of server>

echo "Pre-pulling the image..."
sudo docker pull nginx:latest

function measure_service_startup_time(){
    echo "Measuring the time it takes to start up the service with $1 replicas..."
    start=$(date +%s%N)

    sudo docker service create --name nginx_demo_$1 --replicas $1 nginx
    end=$(date +%s%N)

    # -5 second
    startup_time=$((end - start - 5000000000))
    normalized_time=$(echo "scale=3; $startup_time/1000000000" | bc)
    echo "($1 replicas)Docker startup time with: $normalized_time seconds (Via bash script)"
    sudo docker service rm nginx_demo_$1
}

measure_service_startup_time 1
measure_service_startup_time 5
measure_service_startup_time 10