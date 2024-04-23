pip3 install locust

sudo docker service create --name nginx_demo_10 --replicas 10 -p 80:80 nginx:latest

# locust --headless --users 10 --spawn-rate 1 -H http://$(echo curl http://checkip.amazonaws.com)

locust --headless --users 10 --spawn-rate 1 -H http://54.210.17.24

sudo docker stats