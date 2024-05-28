Komendy uzywane podczas workshop AKS

```bash
# logowanie do az
az login --tenant <TENANT_ID>

# ustawienie zmiennych srodowiskowych

export MY_RESOURCE_GROUP_NAME="glAKSResourceGroup"
export REGION="eastus2"
export MY_AKS_CLUSTER_NAME="glAKSCluster"
export MY_DNS_LABEL="gldnslabel"


# utworzenie resource group
az group create --name $MY_RESOURCE_GROUP_NAME --location $REGION


# utworzenie klastra
az aks create \
        --resource-group $MY_RESOURCE_GROUP_NAME \
        --name $MY_AKS_CLUSTER_NAME \
        --generate-ssh-keys \
        --vm-set-type VirtualMachineScaleSets \
        --load-balancer-sku standard \
        --node-count 1 \
        --zones 2 3

# polaczenie sie do klastra 
az aks get-credentials --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_AKS_CLUSTER_NAME

# informacje o nodach
kubectl get nodes 
kubectl describe nodes | grep -e "Name:" -e "topology.kubernetes.io/zone"
kubectl get nodes -o custom-columns=NAME:'{.metadata.name}',REGION:'{.metadata.labels.topology\.kubernetes\.io/region}',ZONE:'{metadata.labels.topology\.kubernetes\.io/zone}'

# skalowanie klastra
az aks scale \
    --resource-group $MY_RESOURCE_GROUP_NAME \
     --name $MY_AKS_CLUSTER_NAME \
    --node-count 2

##     Mozemy rowniez utworzyc klaster z włączoną opcją automatycznego skalowania klastra:
    az aks create \
        --resource-group $MY_RESOURCE_GROUP_NAME \
        --name $MY_AKS_CLUSTER_NAME \
        --node-count 1 \
        --vm-set-type VirtualMachineScaleSets \
        --load-balancer-sku standard \
        --enable-cluster-autoscaler \
        --min-count 1 \
        --max-count 3


 ##   lub mozemy rózniez zaktualizować istniejący klaster i wlączyć opcję automatycznego skalowania
    az aks update \
        --resource-group $MY_RESOURCE_GROUP_NAME \
        --name $MY_AKS_CLUSTER_NAME \
        --enable-cluster-autoscaler \
        --min-count 1 \
        --max-count 3

# Wdroenie aplikacji
kubectl apply -f aks-store-quickstart.yaml

# info o ip publicznym do serwisu
kubectl get service store-front --output 'jsonpath={..status.loadBalancer.ingress[0].ip}'

# Ręcznie skalowanie klastra
kubectl scale --replicas=5 deployment.apps/store-front 
kubectl get pod # powinnismy widziec 5 PODow dla store-front


# Auntomatyczne skalowanie aplikacji
kubectl apply -f aks-store-hpa.yaml # wdroenie HPA
kubectl get hpa #wylistowanie HPA
kubectl get hpa store-front-hpa --watch




# Prosty przykład ingress
export AKS_RG="jmAKSResourceGroupGL"
export AKS_NAME="jmAKSClusterGL"

AKS_RG_AZ=$(az aks show --resource-group ${AKS_RG} --name ${AKS_NAME} --query nodeResourceGroup -o tsv)

REPLACE_STATIC_IP=$(az network public-ip create --resource-group ${AKS_RG_AZ} --name jmAKSPublicIPForIngress --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv)

kubectl create namespace ingress-basic
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP="REPLACE_STATIC_IP" 

# Lista Service w labela ingress-nginx
kubectl get service -l app.kubernetes.io/name=ingress-nginx --namespace ingress-basic

# Lista PODÓW
kubectl get pods -n ingress-basic
kubectl get all -n ingress-basic


# Wdrozenie
kubectl apply -f aks-nginx/

# Wylistowanie Podów
kubectl get pods

# Wylistowanie service
kubectl get svc

# Wylistowanie Ingress
kubectl get ingress

# dostep do aplikacji
#http://<Public-IP-created-for-Ingress>/app1/index.html
#http://<Public-IP-created-for-Ingress>

# Zweryfikowanie logów z ingresa
kubectl get pods -n ingress-basic
kubectl logs -f <pod-name> -n ingress-basic
```
### Polaczenie klastra z Entra-id 

```bash
# musimy pobrać identyfikator klastra K8s
AKS_ID=$(az aks show \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --query id -o tsv)

# następnie tworzymy grupę w Entra ID for application developers
APPDEV_ID=$(az ad group create --display-name appdev --mail-nickname appdev --query id -o tsv)

# następnie musimy stworzyć role assignmet dla grupy application developers. To pozwoli na to, 
# by kazdy członek grupy mogł uywać kubectl do zarządzania klastrem
az role assignment create \
  --assignee $APPDEV_ID \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope $AKS_ID

# stwórzmy jeszcze jedną grupę dla ops sre engineers
OPSSRE_ID=$(az ad group create --display-name opssre --mail-nickname opssre --query id -o tsv)

# i znow zróbmy przypisanie do roli grupy ops sre inzynierow
az role assignment create \
  --assignee $OPSSRE_ID \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope $AKS_ID

# utorzylismy 2 grupy, więc musimy dodać do tych grup jakichs uytkonikow 
# to pozwoli nam na przetestowanie integracje RBAC Kubernetesowego z Azure Entra ID

# musimy ustawic User Principal Name (UPN) nazwę uzytkonika i haslo dla uytkonika w grupie  application developers
# musimy pamiętać, ze UPN musi zawierać zweryfikowany adres domeny, którą posiadamy dla swojego tenanta - u mnie jest gmail.com
echo "Please enter the UPN for application developers: " && read AAD_DEV_UPN
echo "Please enter the secure password for SREs: " && read AAD_DEV_PW

# Utwórzmy uzytkonika dla grupy Dev
AKSDEV_ID=$(az ad user create \
  --display-name "AKS Dev" \
  --user-principal-name $AAD_DEV_UPN \
  --password $AAD_DEV_PW \
  --query id -o tsv)

#Dodajemy uzytkonika do grupy application developer 
az ad group member add --group appdev --member-id $AKSDEV_ID


# to samo musimy zrobić dla 2 grupy - stworzyc uzytkonika i dodac go do grupy
echo "Please enter the UPN for SREs: " && read AAD_SRE_UPN
echo "Please enter the secure password for SREs: " && read AAD_SRE_PW
AKSSRE_ID=$(az ad user create \
  --display-name "AKS SRE" \
  --user-principal-name $AAD_SRE_UPN \
  --password $AAD_SRE_PW \
  --query id -o tsv)
az ad group member add --group opssre --member-id $AKSSRE_ID

# Teraz tworzymy zasób w AKS dla app developers
az aks get-credentials --resource-group ${MY_RESOURCE_GROUP_NAME} --name ${MY_AKS_CLUSTER_NAME} --admin

# utwórzmy najpier workspace
kubectl create namespace dev

# i zróbmy deployment 
kubectl apply -f role-dev-namespace.yaml
az ad group show --group appdev --query id -o tsv # sprawdzamy

# w kolejnym kroku musimy przypisac grupe w klustrze
kubectl apply -f rolebinding-dev-namespace.yaml 

###--------

# to samo robimy z 2 grupa
kubectl create namespace sre
kubectl apply -f role-sre-namespace.yaml
az ad group show --group opssre --query id -o tsv
kubectl apply -f rolebinding-sre-namespace.yaml

# teeraz przyszedł czas na update naszego klastra
az aks get-credentials --resource-group ${MY_RESOURCE_GROUP_NAME} --name ${MY_AKS_CLUSTER_NAME} --overwrite-existing

###--------

# nastepnie utworzmy pod bazujacy na nginx w namespace dev
kubectl run nginx-dev --image=nginx:1.14.1 --namespace dev

# zostaniemy poproszeni przez azure o zalogowanie sie do klastra 
# To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code XXXXX to authenticate.
# musimy uzyc danych, ktore wpisalismy dla naszego uzytkownika z grup application dev
# po pomyslnym zalokowaniu, nasz pod powinien sie utworzyć
# i mozemy dgo sprawdzic
kubectl get pods --namespace dev

# sprawdzmy pody z innego namespace
kubectl get pods --all-namespaces

# ZADANIE - zrobic to samo, ale dla 2 grupy - SRE

# przelaczenie sie na role admina
az aks get-credentials --resource-group ${MY_RESOURCE_GROUP_NAME} --name ${MY_AKS_CLUSTER_NAME} --admin
```

