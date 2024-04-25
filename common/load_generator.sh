#!/bin/sh

# Read input parameters
locust --headless -t 60s -f ./locust_file.py --users 100 --spawn-rate 100 -H $1