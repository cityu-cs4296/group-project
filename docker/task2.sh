function measure_service_failure(){
    sudo docker service create --name nginx_demo_$1 --replicas $1 -p 80:80 nginx:latest
    echo "(Idle)  Displaying the resource usage of $1 containers"
    sudo docker stats --no-stream
    sudo docker service rm nginx_demo_$1
}

measure_service_failure 1
measure_service_failure 5
measure_service_failure 10
