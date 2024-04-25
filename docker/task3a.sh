# go to the locust machine, need to prepare the locustfile.py first
pip3 install locust
locust --headless --users 10000 --spawn-rate 100 --processes 8 -H http://{public-ip-of-docker}

# for the ip address, to task3b.sh to get the public ip address of the docker machine