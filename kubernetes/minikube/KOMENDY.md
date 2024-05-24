# Minikube -- komendy

Ponizej znajduje się lista komend, które będziemy wykonywać podczas warsztatów 
Komendy dotyczą 

```bash
eval $(minikube docker-env) # Wskazanie terminalowi korzystanie z demona dokowanego w minikube. Dziala tylko w aktywnej sesji terminala

docker ps # wyświetla działające kontenery Dockera

kubectl apply -f nginx-pod.yaml # wdrozenie PODa z Nginx na podstawie deklaratywnego manifestu. Plik manifestu jest w katalogu ./kubernetes/manifests/
kubectl run nginx --image nginx:1.14.2 # alternatywnie, wdrozenie poda imperatywnie 

kubectl get pods # wyświetla listę działających podów
kubectl get pods --watch # tryb watch
kubectl port-forward nginx 1234:80 # przekierowanie portu PODa tak by był dostępny w sieci lokalnej

kubectl rollout status deployment/nginx-deployment
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1

kubectl edit deployment/nginx-deployment # zmien obraz i zapisz mainifest
kubectl describe deployments # podmieniony obraz i nowa replika powinna być zaaplikowana
kubectl rollout status deployment/nginx-deployment # sprawdź status wdroenia 
kubectl get rs # zweryfikuj ilość replic - wylistowana powinna być stara i nowa relika 
kubectl rollout history deployment/nginx-deployment # sprawdzenie historii wdrozenia

kubectl apply -f nginx-statefulset.yaml # wdrozenie stateful obiektu i nginx

#wdrozenie service
# wdrozenie 
kubectl apply -f nginx-service.yaml
# sprawdzenie serivce
kubects get service 

# Żeby móc korzystać z Ingress na minikube, trzeba włączyć dodatkowy plugin w Minikube

minikube addons enable ingress 

kubectl get pods -n ingress-nginx

# tworzymy deployment
kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0

# i sprawdźmy jej stan
kubectl get deployment web 

# wystawmy Deployment do sieci na zdefiniowanym porcie
kubectl expose deployment web --type=NodePort --port=8080

# zweryfikujmy, czy nasz service K8s działa
kubectl get service web

# odwiedźmy naszą usługę przez NodePort uzywając polecenia: (MacOS -komenda musi być wykonana w innym terminalu!!!)
minikube service web --url 

# to teraz wdrózmy Igress dla naszej aplikacji
kubectl apply -f service-ingres.yaml

# weryfikacja adresu IP
kubectl get ingress

# Siec jest limitowana jesli uywamy Docker Driver na MacOS i 
# Node ID jest nieosiągalny bezpośrednio. W nowym terminalu 
# musimy wykonać komende:
minikube tunnel

# Wysłanie zapytania do:
curl --resolve "hello-world.example:80:127.0.0.1" -i http://hello-world.example

# mozna uzyc przegladarki, ale potrzeba dodać do /etc/hosts wpisu 
127.0.0.1 hello-world.example

```bash
kubectl create deployment web2 --image=gcr.io/google-samples/hello-app:2.0
# weryfikacja deploymentu
kubectl get deployment web2 

#wystawienie deploymentu do sieci
kubectl expose deployment web2 --port=8080 --type=NodePort

# edycja service-ingress.yaml - odkomentowanie 2 service
# zaaplikowanie zmian ze zmienionego manifestu
kubectl apply -f service-ingress.yaml

# Tunel - potrzebny tylko dla macOS
minikube tunnel

# wyslanie zapytań do 2 serwisów, ale z tym samym adresem
curl --resolve "hello-world.example:80:127.0.0.1" -i http://hello-world.example
curl --resolve "hello-world.example:80:127.0.0.1" -i http://hello-world.example/v2

```