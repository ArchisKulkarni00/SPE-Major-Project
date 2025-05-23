#!/bin/bash
echo "Switching to linuxboi..."
sudo -u linuxboi -i <<'EOF'
echo "Current user: $(whoami)"
echo "HOME is $HOME"
export MINIKUBE_HOME=$HOME
export KUBECONFIG=$HOME/.kube/config
export PATH=$HOME/bin:$PATH

# Debug
which docker
docker info
minikube version

# Run
minikube start --driver=docker --ssh-ip-address='' --container-runtime=docker --force --no-vtx-check --alsologtostderr

# 1. Apply the namespace first to ensure all other resources referencing it succeed
kubectl apply -f /tmp/ansible-college-chatbot/k8s/project-namespace.yml

# 2. Apply Persistent Volume (PV)
kubectl apply -f /tmp/ansible-college-chatbot/k8s/ollama-pv.yml

# 3. Apply Persistent Volume Claim (PVC)
kubectl apply -f /tmp/ansible-college-chatbot/k8s/ollama-pvc.yml

# 4. Apply deployments
kubectl apply -f /tmp/ansible-college-chatbot/k8s/iiitb-chatbot-deployment.yml
kubectl apply -f /tmp/ansible-college-chatbot/k8s/ollama-deployment.yml
kubectl apply -f /tmp/ansible-college-chatbot-fe/K8s/deployment.yaml

# 5. Apply services
kubectl apply -f /tmp/ansible-college-chatbot/k8s/iiitb-chatbot-service.yml
kubectl apply -f /tmp/ansible-college-chatbot/k8s/ollama-service.yml
kubectl apply -f /tmp/ansible-college-chatbot-fe/K8s/rag-chat-svc.yaml

# 6. Status Check - All resources in iiitb-chatbot namespace
echo -e "\n📦 Verifying Kubernetes Resources in 'iiitb-chatbot' namespace..."

echo -e "\n🔍 Namespaces:"
kubectl get namespaces

echo -e "\n📄 Persistent Volume Claims:"
kubectl get pvc -n iiitb-chatbot

echo -e "\n💾 Persistent Volumes:"
kubectl get pv

echo -e "\n🚀 Deployments:"
kubectl get deployments -n iiitb-chatbot

echo -e "\n🧱 Pods:"
kubectl get pods -n iiitb-chatbot -o wide

echo -e "\n🌐 Services:"
kubectl get svc -n iiitb-chatbot

echo -e "\n📜 Events (last 20 for debugging):"
kubectl get events -n iiitb-chatbot --sort-by=.metadata.creationTimestamp | tail -n 20

EOF
