stage('Installing Hello Word Application') {
  node('master') {

    sh'''
    export PROJECT_ID=ardent-window-285611
    curl https://sdk.cloud.google.com | bash
    export DIRECTORY="/var/jenkins_home/GoogleCloudSDK/google-cloud-sdk/bin"
    if [ ! -d "$DIRECTORY" ]; then
      # Control will enter here if $DIRECTORY doesn't exist.
	    cd /var/jenkins_home
	    wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip -O google-cloud-sdk.zip
	    unzip -o google-cloud-sdk.zip -d ./GoogleCloudSDK/
	    ./GoogleCloudSDK/google-cloud-sdk/install.sh
    fi
    export PATH=/var/jenkins_home/GoogleCloudSDK/google-cloud-sdk/bin:$PATH
    gcloud auth login
#curl -fsSL https://get.docker.com/rootless | sh
#wget https://download.docker.com/linux/static/stable/x86_64/docker-rootless-extras-19.03.12.tgz
#tar -xzvf docker-rootless-extras-19.03.12.tgz
#/var/jenkins_home/workspace/Hello-world/docker-rootless-extras/dockerd-rootless.sh --experimental --storage-driver vfs
    gcloud --quiet components update
    gcloud --quiet components install beta
    
    gcloud config set project $PROJECT_ID
    gcloud --quiet components install kubectl
    echo "project name: $PROJECT_ID"
    
    docker build -t gcr.io/${PROJECT_ID}/bk-hello-app:v2
    gcloud auth configure-docker
    
    docker push gcr.io/${PROJECT_ID}/bk-hello-app:v2
    gsutil acl ch -r -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com
    gsutil acl ch -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com
    gsutil defacl ch -u AllUsers:R gs://artifacts.${PROJECT_ID}.appspot.com
    kubectl create deployment hello-app --image=gcr.io/${PROJECT_ID}/bk-hello-app:v2
    kubectl scale deployment hello-app --replicas=3
    kubectl autoscale deployment hello-app --cpu-percent=80 --min=1 --max=5
    kubectl expose deployment hello-app --name=hello-app-service --type=LoadBalancer --port 11130 --target-port 8080    
    
    '''
   
  }
}
