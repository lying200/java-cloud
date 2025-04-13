#!/bin/bash

# 创建dev命名空间
kubectl create namespace dev

# 在每个节点上创建数据目录
echo "请确保在每个节点上执行以下命令："
echo "sudo mkdir -p /data/vol1 /data/vol2 /data/vol3"
echo "sudo chmod 777 /data/vol1 /data/vol2 /data/vol3"
echo "按任意键继续..."
read -n 1 -s

# 应用存储类配置
echo "应用存储类配置..."
kubectl apply -f storage-class.yaml

# 应用密钥配置
kubectl apply -f secrets.yaml

# postgres初始数据库配置
kubectl create configmap postgres-init-scripts --from-file=create-databases.sql -n dev

# 部署基础设施服务
kubectl apply -f postgres-dev.yaml
kubectl apply -f redis-dev.yaml
kubectl apply -f rabbitmq-dev.yaml
kubectl apply -f monitoring-dev.yaml

# 等待所有Pod就绪
echo "等待服务启动..."
kubectl wait --for=condition=ready pod -l app=postgres -n dev --timeout=300s
kubectl wait --for=condition=ready pod -l app=redis -n dev --timeout=300s
kubectl wait --for=condition=ready pod -l app=rabbitmq -n dev --timeout=300s
kubectl wait --for=condition=ready pod -l app=prometheus -n dev --timeout=300s

# 显示服务状态
echo "显示服务状态..."
kubectl get pods -n dev
