#!/bin/bash


apply() {
  
  $1

  # Verifica o status de saída do comando kubectl
  status_saida=$?

  # Se o status de saída for diferente de zero (indicando erro)
  if [ $status_saida -ne 0 ]; then
    echo "Ocorreu um erro na execução do comando kubectl."
    exit 1  # Encerra o script com código de erro 1
  fi
}

# Applying environment keycloak 
echo "------Create Minikube"
apply "minikube start --memory=20480 --cpus=8  --container-runtime=docker"
#echo "------Preparing to plugins--------"
#echo "------disable storage-provisioner------"
#apply "minikube addons disable storage-provisioner"
#echo "------disable default-storageclass------"
#apply "minikube addons disable default-storageclass"
#echo "------enable volumesnapshots------"
#apply "minikube addons enable volumesnapshots"
#echo "------enable csi-hostpath-driver------"
#apply "minikube addons enable csi-hostpath-driver"
#echo "------Create database service------"
#kubectl patch storageclass csi-hostpath-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
