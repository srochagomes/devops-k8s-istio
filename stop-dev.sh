#!/bin/bash

stopMinikube(){
  echo "Verificando minikube."
  minikube status &> /dev/null

  if [ $? -eq 0 ]; then
    echo "O Minikube será desligado." &
    minikube stop  &
  fi

  return $!
}

stopDockerCompose(){
  echo "Verificando Docker-compose."
  sudo docker-compose kill

  return $!
}

stopDatabaseKeycloak(){
  DOCKER_COMPOSE_FILE="docker-compose.yml"

  if netstat -tuln | grep ":5432 " > /dev/null; then
    echo "O banco de dados será desligado." 
    sudo docker-compose -f $DOCKER_COMPOSE_FILE down &
  fi
  
  
  return $!
  
}

stopApiGateway(){
  PORTA=8885

  # Encontra o PID do processo utilizando a porta
  PID=$(lsof -t -i :$PORTA)

  # Verifica se o PID foi encontrado
  if [ -n "$PID" ]; then
    # Encerra o processo
    echo "O APIGateway processo na porta $PORTA será encerrado (PID: $PID)."
    sudo kill -2 $PID 
    
  fi
  
  return $!
}

stopAuthBase(){
  PORTA=8887

  # Encontra o PID do processo utilizando a porta
  PID=$(lsof -t -i :$PORTA)

  # Verifica se o PID foi encontrado
  if [ -n "$PID" ]; then
    # Encerra o processo
    echo "O AUTH processo na porta $PORTA será encerrado (PID: $PID)."
    sudo kill -2 $PID    
  fi
  
  return $!
  
}


#pidDB= stopDatabaseKeycloak
pidMK= stopMinikube
#pidAPIGat= stopApiGateway
#pidAuth= stopAuthBase
pidDK= stopDockerCompose
#wait $pidDB
wait $pidMK
wait $pidDK
#wait $pidAPIGat
#wait $pidAuth


echo "Ambiente Encerrado."

