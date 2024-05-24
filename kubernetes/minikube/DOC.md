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

### Uruchomienie POD z Nginx

Najpierw musimy zdefiniować plik manifestu. Jest to prosta, deklaratywna definicja, zawierająca opis obektów kubernetesowych.
Plik ten jest pisany w YAMLu, bądź JSONie i podstawowym sposobem zarządzania obiektami kubernetesowymi.

```yaml - zapisz plik nginx-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```
Zeby uruchomić POD, nalezy wykonać polecenie:

```bash
kubectl apply -f nginx-pod.yaml
```

Mozna rowniez uruchomic POD bez pliku manifest, ale podając jego konfigurację w ``kubectl``

```bash
kubectl run nginx --image nginx:latest
```

Te 2 przykłady uruchamiania PODa pokazują róznicę między konfiguracją delaratywną i imperatywną. 
W podejściu imperatywnym musimy uzyć określonych poleceń, aby poinstruować K8s, jak ukończyć utworzenie PODa.
Gdy uywamy deklaratywnym plików manifest, K8s "uzgadania" zawartość pliku z istniejącym stanem klastra, a następnie wykonuje 
potrzebne akcje automatycznie, by klaster osiągnął swój stan.

### Weryfikacja czy POD dziala

```bash
kubectl get pods
kubectl get pods --watch
kubectl port-forward nginx 1234:80
```
Mamy 1 PODa, a co jeśli chcemy mieć więcej podów neginx?

### Deployment
Z pomocą przychodzi Deployment.
```bash
kubectl apply -f nginx-deployment.yaml
```
Co tu się wydarzyło?
*   Deployment ``nginx-deployment`` został utworzony -- ``kubectl get deployments.app`` 
    Nazwa deploymentu będzie następnie powtórzona dla PODa i ReplicaSet 
* Deployment utworzył obiekt ReplicaSet, która z kolei utworzy 3 repliki PODów - ``kubectl get replicasets.app`` i ``kubectl get pods``
* ``.spec.selector`` mówi nam jak ReplicaSet będzie znajdować PODy, którymi ma zarządzać. 
    W naszym przykładzie ReplicaSet będzie szukać PODów, których labela jest zdogna z ``app: nginx``
* Wszystkie uruchomione repliki będa mieć labelę ``app:nginx`` poniewaz jest ona zdefiniowana w templacie w pliku manifestu.

No dobra, ale jak mamy wiecej róznych obiektow K8s w deploymentcie, to chyba nie bedziemy wszystkich ich wyświetlać, zeby 
zweryfikować, czy działaja? Z pomocą przychodzi polecenie:

```bash
kubectl rollout status deployment/nginx-deploymen
```

#### A co jeśli chcemy zupdatować wersję Nginx?
Obecnie w pliku manifest mamy wersję 1.14.2, a chcemy mieć 1.16.1. Mozemy to zrobić na kilka sposobów:
1. Imperatywnie aktualizując działający deployment, ustawiając nową wersję obrazu

```bash
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1
```
1. Deklaratywnie, poprzez zmiane deploymentu:

```bash
kubectl edit deployment/nginx-deployment #zmien obraz i zapisz
kubectl describe deployments #podmieniony obraz i nowa replika
kubectl rollout status deployment/nginx-deployment 
kubectl get rs # stara i nowa relika 
kubectl rollout history deployment/nginx-deployment # sprawdzenie historii 
```

Procz deploymentu mozemy stworzyć rowniez inne rodzaje workloadu. Mozemy np utworzyć ReplicaSet. Obiekt ten gwarantuje, ze 
wyspecyfikowana ilość replik (w naszym przypadku PODów) działa w dowolnym momencie.
Ale, Deployment tworzy nam tez obiekty typu ReplicaSet. Deployment jest koncepcją wyszego poziomu, bo nie tylko zarządza 
replikami i podami, ale daje większe mozliwosci - chociazby mozliwosc aktualizacji. Zalecane jest zatem, zeby uzywac Deployment. 

### Kolejne obiekty -- StatefulSet 
StatefulSet słuzy głownie do zarządzania obiektami z aplikacjami stanowymi, czyli tam gdzie proces umozliwia przechowwywanie
i rejestrowanie informacji oraz mozliwy jest powrót do tych informacji (czyli do stanu). Stan przechowywany jest zwykle po stronie 
serwera, dlatego w Stateful obiektach wazna jest ich unikalnosc i kolejnosc. Zwykle uzywane są do aplikacji z bazami danych, albo 
danych zapisanych na dysku twardym. 

```bash
kubectl apply -f nginx-statefulset.yaml # wdrozenie stateful obiektu i nginx
```
* Wdrozony został obiekt typu service ``nginx`` (headless service), który jest uywany do kontrolowania domeny - tutaj lokalhost
* Mamy rózniez obiekt Stateful, nazwany ``web``, który posiada 3 repliki. Kazda replika będzie uruchomiona w unikalnym PODzie.
* Utworzony zostaje tez obiekt ``PersistentVolumes`` - trwała pamięc dyskowa, którą musimy zaalokować. Typ klasy ``storage class``  
zalezy od dostawcy chmurowego. Dla Azure moze to byc ``managed-csi`` - standardowy lokalny dysk SSD. 