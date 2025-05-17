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
kubectl apply -f /tmp/ansible-college-chatbot/k8s/iiitb-chatbot-namespace.yml

# 2. Apply Persistent Volume (PV)
kubectl apply -f /tmp/ansible-college-chatbot/k8s/ollama-pv.yml

# 3. Apply Persistent Volume Claim (PVC)
kubectl apply -f /tmp/ansible-college-chatbot/k8s/ollama-models-pvc.yml

# 4. Apply deployments (for chatbot and ollama)
kubectl apply -f /tmp/ansible-college-chatbot/k8s/iiitb-chatbot-deployment.yml
kubectl apply -f /tmp/ansible-college-chatbot/k8s/ollama-deployment.yml

# 5. Apply services (requires namespace to already exist)
kubectl apply -f /tmp/ansible-college-chatbot/k8s/iiitb-chatbot-service.yml
kubectl apply -f /tmp/ansible-college-chatbot/k8s/ollama-service.yml

EOF
