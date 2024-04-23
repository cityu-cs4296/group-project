# require two terminal to run this scripts

# 1st, set up a monitor script to monitor the docker events
sudo yum install jq
function monitor_service_event(){
    echo "Monitoring Docker events..."
    sudo docker events --format '{{json .}}' | while read event
    sudo docker ps
    do
    STATUS=$(echo $event | jq -r '.status')
    CONTAINER_ID=$(echo $event | jq -r '.id')
    TIME=$(echo $event | jq -r '.time')
    echo "Container $CONTAINER_ID $STATUS at $TIME"
    done
}

monitor_service_event

#////////////////////////////////////////////////////////////////
# run the two scripts in seperate terminal
#////////////////////////////////////////////////////////////////

# 2nd, set up a script to create a service, and stop some of the containers to demo the case of failure
function measure_service_failure(){
    sudo docker service create --name nginx_demo_$1 --replicas $1 -p 80:80 nginx:latest
    sudo docker stop $(sudo docker ps -a -q)
    sudo docker service rm nginx_demo_$1
}

measure_service_failure 1
measure_service_failure 5
measure_service_failure 10
