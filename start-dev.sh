#!/bin/bash

apply() {

  $1 

  # Verifica o status de saída do comando kubectl
  status_saida=$?

  # Se o status de saída for diferente de zero (indicando erro)
  if [ $status_saida -ne 0 ]; then
    echo "Ocorreu um erro na execução do comando."
    exit 1  # Encerra o script com código de erro 1
  fi
}


waitService(){
  PORTA=$1 

  # Aguarda até que a porta esteja ativa
  while ! netstat -tuln | grep ":$PORTA " > /dev/null; do
      sleep 1
  done

  # A porta está ativa, continue com o restante do script
  echo "A porta $PORTA está ativa."
}


startDockerCompose(){
  echo "Verificando DockerCompose."
  sudo docker-compose build && sudo docker-compose up -d
  return $!
}


startMinikube(){
  echo "Verificando minikube."
  minikube status &> /dev/null

  if [ $? -eq 0 ]; then
    echo "O Minikube está ativo." &
  else
    echo "O Minikube será iniciado."
    apply "minikube start"
  fi

  return $!
}


startDatabaseKeycloak(){
  DOCKER_COMPOSE_FILE="docker-compose.yml"

  if netstat -tuln | grep ":5432 " > /dev/null; then
    echo "O banco de dados já está ativo." &
  else
    echo "O Serviço de banco de dados será iniciado."
    sudo docker-compose build 
    sudo docker-compose up -d &
  fi
  
  
  return $!
  
}

startApiGateway(){
  # Diretório do arquivo POM
  POM_DIRECTORY="/home/programmer/desenvolvimento/testes/api-gateway"

  # Caminho completo para o arquivo POM
  POM_FILE="$POM_DIRECTORY/pom.xml"
  

  if netstat -tuln | grep ":8885 " > /dev/null; then
    echo "O APIGateway já está ativo." &
  else
    echo "O Serviço de APIGateway será iniciado."
    # Executa o mvn com o arquivo POM em outro diretório
    apply "mvn -f $POM_FILE spring-boot:run" &
  fi
  
  return $!
}

startAuthBase(){
  # Diretório do arquivo POM
  POM_DIRECTORY="/home/programmer/desenvolvimento/testes/auth-api"

  # Caminho completo para o arquivo POM
  POM_FILE="$POM_DIRECTORY/pom.xml"
  

  if netstat -tuln | grep ":8887 " > /dev/null; then
    echo "O AuthBase já está ativo." &
  else
    echo "O Serviço de AuthBase será iniciado." &
    # Executa o mvn com o arquivo POM em outro diretório
    apply "mvn -f $POM_FILE spring-boot:run" &
  fi
  
  return $!    
  
}

startDockerCompose

#startDatabaseKeycloak
startMinikube
#startApiGateway
#startAuthBase

#echo "Aguardando os processos"
#waitService 5432
#waitService 8885
#waitService 8887

sudo systemctl restart nginx

echo "Ambiente Configurado."

