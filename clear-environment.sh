#!/bin/bash

# Definindo variáveis
NAMESPACE="app-env"
RESOURCE_NAMESPACE="namespace/"
RESOURCE_CONFIGMAP="config-map/"
DIR_INFRA="infraestructure"
RESOURCE_LIMITS=$DIR_INFRA"/limits/"
RESOURCE_DATABASE=$DIR_INFRA"/database"
RESOURCE_VOLUME=$RESOURCE_DATABASE"/keycloak-database-persistent-volume.yaml" 
RESOURCE_DATABASE_STATEFUL=$RESOURCE_DATABASE"/keycloak-database-statefull-set.yaml" 
RESOURCE_DATABASE_SERVICE=$RESOURCE_DATABASE"/keycloak-database-service.yaml"


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

unInstallIstio(){
  NAMESPACE_ISTIO="istio-system"
  NAMESPACE_APP="app-env"
  echo "------Uninstalling Istio--------"
  export PATH=$PWD/istio-1.17.1/bin:$PATH
  apply "istioctl uninstall --purge -y"
  apply "kubectl delete namespace $NAMESPACE_ISTIO"
  echo "------removing application--------"
  apply "kubectl delete namespace $NAMESPACE_APP"
}

unInstallIstio
