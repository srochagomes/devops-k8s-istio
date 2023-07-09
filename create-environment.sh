#!/bin/bash

# Definindo variáveis
NAMESPACE="app-env"
RESOURCE_NAMESPACE="namespace/"
RESOURCE_CONFIGMAP="config-map/"
DIR_INFRA="infraestructure"
DIR_APP="application"
DIR_KEYCLOAK=$DIR_APP"/keycloak"
RESOURCE_LIMITS=$DIR_INFRA"/limits/"
RESOURCE_DATABASE=$DIR_INFRA"/database"
RESOURCE_VOLUME=$RESOURCE_DATABASE"/keycloak-database-persistent-volume.yaml" 
RESOURCE_DATABASE_STATEFUL=$RESOURCE_DATABASE"/keycloak-database-statefull-set.yaml" 
RESOURCE_DATABASE_SERVICE=$RESOURCE_DATABASE"/keycloak-database-service.yaml"
RESOURCE_KEYCLOAK_STATEFUL=$DIR_KEYCLOAK"/keycloak-statefull.yaml" 
RESOURCE_KEYCLOAK_SERVICE=$DIR_KEYCLOAK"/keycloak-service.yaml"
RESOURCE_KEYCLOAK_HPA=$DIR_KEYCLOAK"/keycloak-hpa.yaml"

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

installIstio(){
    # Nome do namespace que você deseja verificar
    NAMESPACE_ISTIO="istio-system"

    # Verifica se o namespace já existe usando o kubectl
    if kubectl get namespace $NAMESPACE_ISTIO &> /dev/null; then
        echo "Istio já instalado"
    else
        echo "------Installing Istio--------"
        export PATH=$PWD/istio-1.17.1/bin:$PATH
        apply "istioctl install --set profile=default -y --set values.global.jwtPolicy=third-party-jwt"
        echo "------Configure injection sidecar Istio--------"
        apply "kubectl label namespace default istio-injection=enabled --overwrite"
        apply "kubectl label namespace app-env istio-injection=enabled --overwrite"
        echo "------Apply all addons--------"
        kubectl apply -f istio-1.17.1/samples/addons
    fi
}

#Verificar metricas
#kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Applying environment keycloak 
echo "------Create namespace: $NAMESPACE"
apply "kubectl apply -f $RESOURCE_NAMESPACE"
echo "------Preparing to install Istio--------"
installIstio
echo "------Create limits------"
apply "kubectl apply -f $RESOURCE_LIMITS"
echo "------Create config-maps------"
apply "kubectl apply -f $RESOURCE_CONFIGMAP"
#echo "------Create volumes------"
#apply "kubectl apply -f $RESOURCE_VOLUME"
#echo "------Create database stateful------"
#apply "kubectl apply -f $RESOURCE_DATABASE_STATEFUL"
#echo "------Create database service------"
#apply "kubectl apply -f $RESOURCE_DATABASE_SERVICE"
echo "------Create keycloak stateful------"
apply "kubectl apply -f $RESOURCE_KEYCLOAK_STATEFUL"
echo "------Create keycloak service------"
apply "kubectl apply -f $RESOURCE_KEYCLOAK_SERVICE"
echo "------Create keycloak hpa------"
apply "kubectl apply -f $RESOURCE_KEYCLOAK_HPA"
