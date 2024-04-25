# require two terminal to run this scripts

# 1st, set up a monitor script to monitor the docker events
sudo apt install jq
function monitor_service_event(){
    echo "Monitoring Docker events..."
    sudo docker events --format '{{json .}}' | while read event
    # sudo docker ps
    do
    STATUS=$(echo $event | jq -r '.status')
    CONTAINER_ID=$(echo $event | jq -r '.id')
    TIME=$(echo $event | jq -r '.time')
    echo "Container $CONTAINER_ID $STATUS at $TIME"
    done
}

monitor_service_event


