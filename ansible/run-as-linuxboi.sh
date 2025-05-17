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
minikube start --driver=docker --ssh-ip-address='' --container-runtime=docker --force --no-vtx-check --alsologtostderr --v=1
EOF
