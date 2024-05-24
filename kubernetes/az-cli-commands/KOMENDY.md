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


