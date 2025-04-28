#!/bin/bash

# Set up Kubernetes on a single node
minikube start --driver=docker
kubectl create namespace missan-ai
