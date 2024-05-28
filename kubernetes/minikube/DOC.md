# Kubernetes – podstawy

## Tworzenie POD - na przykładzie deploymentu Nginx na lokalny kluster (minikube)

### Uruchomienie środowiska lokalnego
Aby móc uruchomić kontener działający w podzie na minikube, musimy posiadać obraz kontenera. 
Jeśli np naszym lokalnym środowiskiem uruchomieniowym jest Docker, mozemy re-uzyć Docker Daemon 
w klastrze minikube. Oznacza to, że nie musimy budować obrazu na komputerze hosta, lokalnie, 
i wypychać obrazu do rejestru dokera. Możesz po prostu uzyć tego samego Docker Demona w naszym lokalnym minikube.
To przyspiesza lokalne eksperymenty. 

*Pamiętaj, zeby wystartować Docker desktop, lub serwis dockera i minikube!*

Aby wskazać terminalowi korzystanie z demona dokowanego w minikube, musimy wywołać komendę:

```bash
eval $(minikube docker-env)
```

Od teraz każde polecenie dockerowe uruchomione w bieżącym terminalu będzie działać wewnątrz klastra minikube.

Jeśli więc wykonamy polecenie:

```bash
docker ps
```   
wyświetlą się nam kontenery działające wewnątrz minikube.

Są dostępne inne sposoby do wypychania obazów do minikube:
https://minikube.sigs.k8s.io/docs/handbook/pushing/#1-pushing-directly-to-the-in-cluster-docker-daemon-docker-env 
