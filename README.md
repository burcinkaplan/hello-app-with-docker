Launch and manage a GKE cluster using Terraform.
## Prerequirements

installation google-cloud-sdk
```
$curl https://sdk.cloud.google.com | bash
```
Create Service Account in GCP and downloaded it after that export it

```
IAM & Admin -> Service Accounts -> Create Service Accounts -> Name it -> Select role -> Done

```
![alt text](https://github.com/burcinkaplan/hello-app-with-docker/blob/master/SA.png)

```
Download the sa.json file and export it.
```
![alt text](https://github.com/burcinkaplan/hello-app-with-docker/blob/master/SA-json-install.png)

```
$export GOOGLE_APPLICATION_CREDENTIALS="$PATH/auth-gcp.json"
```
installation terraform for MacOS
```
$curl -O https://releases.hashicorp.com/terraform/0.14.9/terraform_0.14.9_darwin_amd64.zip
$unzip terraform_0.14.9_darwin_amd64.zip
$cp terraform /usr/local/bin
$chmod 755 /usr/local/bin/terraform
```
installation helm for MacOS
```
$brew install kubernetes-helm
$helm repo add stable https://charts.helm.sh/stable
```
install docker for MacOS
```
$brew install --cask docker; open /Applications/Docker.app
```

## Configure Project variables
Should configure variables.tf file accourding to your project.

Register Gcloud Project
```
$gcloud auth login
$gcloud init
$gcloud components update
$gcloud components install kubectl
$gcloud config set project $PROJECT_ID
```
## Launch GKE Cluster
```
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```
*Note: It will take 10 minutes for the load balancer to provision*

## Launch Jenkins

First, you will need to authenticate to the cluster, then you can run the following:
```
$gcloud container clusters get-credentials <ClusterName> --zone us-central1-a --project <PROJECT_ID>
```
Jenkins user/pass set by default : admin/admin
```
$helm install blue stable/jenkins -f values-latest-jenkins.yaml
```
Display Jenkins External-IP Address:
```
$kubectl get svc
```
Jenkins External IP URL;
```
http://<ExternalIP>:8080
```

## Launch Hello World Application

You can run the following for Expose the Hello-World Application

```
$gcloud container clusters get-credentials <ClusterName> --zone us-central1-a --project <PROJECT_ID>
$cd app-hello
$export PROJECT_ID=<ProjectID>
$docker build -t gcr.io/${PROJECT_ID}/bk-hello-app:v1 
$gcloud auth configure-docker
$docker push gcr.io/${PROJECT_ID}/bk-hello-app:v1
```
Make all current objects in the bucket public (eg, the image you just pushed):
```
gsutil acl ch -r -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com
```
Make all future objects in the bucket public:
```
gsutil defacl ch -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com
```


Create Deployment and configuring scale and autoscale
```
$kubectl create deployment hello-app --image=gcr.io/${PROJECT_ID}/bk-hello-app:v1
$kubectl scale deployment hello-app --replicas=3
$kubectl autoscale deployment hello-app --cpu-percent=80 --min=1 --max=5
$kubectl expose deployment hello-app --name=hello-app-service --type=LoadBalancer --port 11130 --target-port 8080
```
Display Hello-World App External-IP Address:
```
$kubectl get svc
```
Application URL:
```
http://<ExternalIP>:11130
```

## Launch New Version of Hello World Application
```
$docker build -t gcr.io/${PROJECT_ID}/bk-hello-app:v2 .
$docker push gcr.io/${PROJECT_ID}/bk-hello-app:v2
$kubectl set image deployment/hello-app hello-app=gcr.io/${PROJECT_ID}/bk-hello-app:v2
```

## For Cleaning Environment please Run these commands
```
$kubectl delete service hello-app-service
$gcloud container clusters delete <ClusterName> --quiet
```
