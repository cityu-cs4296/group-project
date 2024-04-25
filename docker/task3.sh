# go to the locust machine, need to prepare the locustfile.py first
pip3 install locust
locust --headless --users 10000 --spawn-rate 100 --processes 8 -H http://{public-ip-of-docker}

# go to the docker machine
# get the public IP of the docker machine 
curl http://checkip.amazonaws.com
# output: e.g. 54.210.17.24

sudo docker service create --name nginx_demo_10 --replicas 10 -p 80:80 nginx:latest
sudo docker stats
