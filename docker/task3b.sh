# get the public IP of the docker machine 
curl http://checkip.amazonaws.com
# output: e.g. 54.210.17.24

sudo docker service create --name nginx_demo_10 --replicas 10 -p 80:80 nginx:latest
sudo docker stats