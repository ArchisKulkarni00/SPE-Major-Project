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
minikube start --driver=docker
EOF
