# Aby móc korzystać z azure-cli potrzebne jest posiadanie subskryptci Azure.

# Tworzenie krok po kroku klastra Kubernetes na platformie Azure 

1. Logowanie do Azure:
```bash
az login --tenant <TENANT_ID>
```

1. Zdefiniuj zmienne środowiskowe:
    ```bash
    export MY_RESOURCE_GROUP_NAME="jmAKSResourceGroupGL"
    export REGION="eastus2"
    export MY_AKS_CLUSTER_NAME="jmAKSClusterGL"
    export MY_DNS_LABEL="jmdnslabelgl"
    ```

1. Utwórz Resource Groupę (RG):
RG, Grupa Zasobów jest to kontener, kolekcja, które przechowuje powiązane zasoby chmurowe na platformie Azure. 
    ```bash
    az group create --name $MY_RESOURCE_GROUP_NAME --location $REGION
    ```

1. Utwórz kluster Kubernetes
    ```bash
    az aks create \
        --resource-group $MY_RESOURCE_GROUP_NAME \
        --name $MY_AKS_CLUSTER_NAME \
        --generate-ssh-keys \
        --vm-set-type VirtualMachineScaleSets \
        --load-balancer-sku standard \
        --node-count 1 \
        --zones 2 3
    ```

    Podczas tworzenia nowego klastra usługa AKS automatycznie tworzy drugą resource group (RG), w której przechowuje zasoby AKS 
    ```MC_jmAKSResourceGroup_jmAKSCluster_westeurope``` i jest to grupa nazywana "node resource group". Grupa ta zawiera między innymi:
    wirtualne maszyny (VM), wirtualną sieć oraz magazyn davych (storage). RG zostanie usunięta automatycznie, w momencie usunięcia 
    klastra AKS.

1. Połącz się do swojego klastra K8s
    ```bash
    az aks get-credentials --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_AKS_CLUSTER_NAME
    ```

1. Zweryfikuj połączenie za pomocą managera zasobów ``kubectl``
    ```bash
    kubectl get nodes
    ```

1. Wyświetlmy liczbę węzłów w klastrze:
    ```bash
    kubectl describe nodes | grep -e "Name:" -e "topology.kubernetes.io/zone"
    kubectl get nodes -o custom-columns=NAME:'{.metadata.name}',REGION:'{.metadata.labels.topology\.kubernetes\.io/region}',ZONE:'{metadata.labels.topology\.kubernetes\.io/zone}'
    ```
 
1. Skalowanie klastra

    ```sh
    az aks scale \
        --resource-group $MY_RESOURCE_GROUP_NAME \
        --name $MY_AKS_CLUSTER_NAME \
        --node-count 2
    ```

    Mozemy rowniez utworzyc klaster z włączoną opcją automatycznego skalowania klastra:

    ```sh
    az aks create \
        --resource-group $MY_RESOURCE_GROUP_NAME \
        --name $MY_AKS_CLUSTER_NAME \
        --node-count 1 \
        --vm-set-type VirtualMachineScaleSets \
        --load-balancer-sku standard \
        --enable-cluster-autoscaler \
        --min-count 1 \
        --max-count 3
    ```

    lub mozemy rózniez zaktualizować istniejący klaster i wlączyć opcję automatycznego skalowania

    ```sh
    az aks update \
        --resource-group $MY_RESOURCE_GROUP_NAME \
        --name $MY_AKS_CLUSTER_NAME \
        --enable-cluster-autoscaler \
        --min-count 1 \
        --max-count 3
    ```
    
1. Wdrozenie aplikacji
By móc wdrozyc aplikacje, potrzebujemy pliku manifest, w ktorym znajdują definicje obiektów. Plik Kubernetes Manifest definiuje
wymagany stan klastra -- czyli jakie obrazy kontenerów powinny zostać uruchomione i w jakiej ilości, definicja service oraz 
deployment.

Posłuzymy sie do tego [AKS Store Application](https://github.com/Azure-Samples/aks-store-demo)
![image info](../imgs/aks-store-architecture.png)

Link to GitHub with [Azure Samples](https://github.com/Azure-Samples/aks-store-demo)
Aplikacja sklada się z:
    * Store front: serwis internetowy dla klientów, gdzie mogą oglądać produkty i składać zamówienia
    * Product service: Wyświetla informacje o produktach
    * Order service: Składanie zamówień
    * Rabbit MQ: Kolejkowanie wiadomości (Message Queue) dla przychodzących zamówień

    ```bash
    kubectl apply -f aks-store-quickstart.yaml
    ```