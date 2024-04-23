## Task 1: Evaluation of Startup Time

1 Replicates (0.925 sec)
![result of 1 replicate](resource/image.png)

5 Replicates (2.774 sec)
![result of 5 replicate](resource/image-1.png)

10 Replicates (4.977 sec)
![result of 10 replicate](resource/image-2.png)

## Task 2: Resource Usage
Resource usage of 1 containers
![idle 1](resource/image-11.png)

Resource usage of 5 containers
![idle 2](resource/image-12.png)

Resource usage of 10 containers
![idle 3](resource/image-13.png)

## Task 3: Load Balancing Efficiency
The result of load balancing
We have used locust.io to create a 100 user traffic/second to our server, 
![alt text](image-1.png)
The result of our 10 containers have average 1.5% of cpu usage,
and you can see from the graph, the traffic are balancely loaded between replicate.
![load balacing result](image.png)

## Task 4: Failure Recovery Time
Demostrate response time of starting a container when one is failed.

it takes 1s seconds for failure recovery of 1 containers
`
    1713885548-1713885547 = 1s
`
![1 containers start](resource/image-6.png)


it takes 24s seconds for failure recovery of 5 containers
`
    1713886048-1713886045 = 3s
`
![5 containers start](resource/image-9.png)
![5 containers end](resource/image-10.png)

it takes 24s seconds for failure recovery of 5 containers
`
    1713885791-1713885783 = 8s
`
![10 containers start](resource/image-8.png)
![10 containers end](resource/image-7.png)

## Task 5: Auto Scaling
We didn't test here, since Auto Scaling is not originally provided by docker.
It is more difficult / complicate to do autoscaling compare to k8s/mesos.