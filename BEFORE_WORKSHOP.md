# Prerekwizyty

## Instalacja niezbędnego oprogramowania

Aby móc aktywnie uczestniczyć w warsztatach o Kubernetes i Azure Kubernetes Service, 
nalezy przygotować swoje lokalne środowisko do pracy. 
W tym celu konieczne jest zainstalowanie dodatkowego oprogramowania i upewnienia się,
ze oprogramowanie działa poprwawnie. 

Wymagane oprogramowanie jest darmowe i dostępne na większość popularnych systemów operacyjnych.

Poniewaz kazdy system operacyjny korzysta z innych managerów pakietów, nie będziemy tutaj dodawać instrukcji 
krok po kroku, jak zainstalować wymagane oprogramowanie. Wierzymy natomiast, ze podlinkowanie dokumentacji
dla wszystkich potrzebnych narzędzi będzie bardzo pomocne :)

* Docker - https://docs.docker.com/engine/install/

* Minikube - https://minikube.sigs.k8s.io/docs/start/

* Helm- https://helm.sh/docs/intro/install/

* kubectl - https://kubernetes.io/docs/tasks/tools/

* Terraform - https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

* Lense - https://docs.k8slens.dev/getting-started/install-lens/


## Utworzenie subskrypcji na Azurze 
Podczas warsztatów, będziemy tworzyć i konfigurować klaster kubernetesowy na platformie Azure. 
Żeby móc to zrobić, nalezy wcześniej stworzyć własną subskrypcję na Azure Portal.

Azure pozwala na stworzenie konta oraz subskrypcji bezpłatnie. Przez okres 30 dni od daty 
stworzenia konta jest ono bezpłatne. Na start dostaje się $200 do wykorzystania w okresie
maksymlnie 30 dni. 

https://azure.microsoft.com/pl-pl/free/
