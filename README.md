Devops Case Documentation
Havva Nur Ozen
---------------------
Case Description

The devops project given to me has a total of 4 phases. When finished I will have an application deployed and synced in ArgoCd. I will outline the phases below, one by one.
•	Phase 1: Creating an app and writing a docker file that contains an entrypoint.sh inside of the docker file which will print “hello world!” in the terminal.
•	Phase 2: Creating an infrastructure repository and set up Kustomize for the same application (Deployment).
•	Phase 3: Adding a GitHub action that uses Kustomize file from the infrastructure repository to deploy the updated version of this deployment to the relevant Kubernetes cluster using ArgoCD.
•	Phase 4: Creating an ArgoCD application.
To do each of these phases I needed to learn a few things:
•	GitOps
•	ArgoCD
•	Kubernetes
•	Kustomize
•	YAML
•	GitHub action
•	CI/CD
•	Kubectl
•	Bash
---------------------
Application Details

In this section I’ll be explaining each of the code pieces I’ve written. Before I can do so I want to provide my application’s structure below:

html-gitops
├── app
│   ├── index.html
├── base
│   ├── configMap.yaml
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   ├── namespace.yaml
│   └── service.yaml
└── overlays
    ├── production
    │   ├── configMap.yaml
    │   ├── deployment.yaml
    │   └── kustomization.yaml
    └── staging
        ├── configMap.yaml
        └── kustomization.yaml
├── Dockerfile
├── prod-codefresh.yml
├── staging-codefresh.yml
├── entrypoint.sh
└── application.yaml

Firstly, we’ll be looking inside of my ‘app’ folder. This folder contains the application I will be deploying. In this case I have a simple HTML file ‘index.html’ which outputs a simple site writing “Hello, ArgoCD!”. 

Our next folder is the ‘base’ folder, which contains five YAML files. The description of each file is as follows:
•	configMap: This has the data I am using in the project. If this project was more complex, then for example in the data part I would maybe write the SQL location. But in this case, I wrote down the html file in my app folder.
•	deployment: This YAML file specifies the image used and checks that the number of pods that are running are correct. The deployment handles updates.
•	kustomization: The kustomize YAML tells how to kustomize Kubernetes resources in this case the resources are the other YAML files in this folder.
•	namespace: This is obvious but shortly I can say that it creates namespaces.
•	service: This part defines a way to access a set of pods as a network service. So, my service is a ‘NodePort’ service that exposes port 80 and forwards traffic to port 80 on pods with the label ‘deployment: html-app’.

Now we have our ‘overlays/production’ folder which includes three YAML files. Each file is described below: 
•	configMap: This config map is no different from the “configMap.yaml” file under the ‘base’ folder.
•	deployment: Here the deployment YAML maintains one replica of a pod with the label ‘environment: production’. (There is no specific reason for the one replica I can have more)
•	kustomization: Here even though it looks different the only reason is that this kustomization is differs from the one in ‘base’ is because we used the command “kustomize edit fix” which fixes the kustomization file in the directory we are in.

The final directory is the ‘overlays/staging’ directory, which holds two YAML files. A description of each file is provided below:
•	configMap: This is the same as the configMap located in the ‘base’ folder.
•	kustomization: The same description as the kustomization file found in ‘overlays/production’ goes for this kustomization YAML.

As you can see in the application structure some of the files aren’t inside of a folder. I will be describing these files in detail below:
•	Dockerfile: A docker file is a file that we write to create an image that we specifically need for a project. In this case my docker file gets the image ‘nginx:alpine’ (base image) and on top of that image I added specific needs for this case. The work directory is set to “/usr/share/nginx/html” (this is where nginx serves static files). Then the ‘index.html’ is copied to the current work directory. And finally, the port listening in port 80.
•	entrypoint.sh: Prints “Hello World” in the terminal when the docker file is in the running phase.
•	application.yaml: The application YAML which was added after an error specifies the details of the app we want to create on argocd.
•	prod-codefresh.yml:
•	staging-codefresh.yml: This file is basically the same as the ‘prod-codefresh.yml’ file the only difference is that this uses the ’kubectl apply -k’ command in the ‘overlays/staging’ folder.
---------------------
Deployment Process 

To deploy this simple html application, I first had to build an image and run the image. Then I was able to use “kubectl apply -k overlay/staging” to update my Kubernetes cluster using Kustomize. 
After that I logged into argocd and created an app but for some reason the application wouldn’t sync no matter what I did. It turned out that the problem was that the image that I created in docker couldn’t get in touch with Kubernetes because the image is in my local registry.

 To solve this problem, I first created a registry and build an image again. But this time when I built the image I also pulled and pushed it inside of the registry and also I went inside of minikube with the command “minikube ssh” and did all the necessary things there (building, pulling, pushing and running the image “localhost:5000/hav1s/html-gitops-img:v1.0.1”).
 
The last part that I did before finishing the whole case is explained in the next section.
---------------------
Final Error Fix

The last error that I encountered was “FATA [0000] rpc error: code = InvalidArgument desc = app is not allowed in project "html-devops-proj" when creating the app”. I was getting this error when I wanted to create an app on argoCD. To solve this error, we got rid of all the “app: “parts in the YAML files. Then we went to the argoCD UI and tried to create the application there and it worked. But we still couldn’t create the application in argoCD CLI. So with some codes my mentor created a “test.yaml” file which contains the details of the application we could create in the argoCD UI. He then compared the application we could create to the application we couldn’t create. They were both very similar, but we then found out that as we were trying to create the application using “argocd app create” the application name I used was “hav1s/htmlapp” the “/” was causing a problem so we changed it to “hav1s-htmlapp” and then we got another error that made us change the position of the “- -project default” part. To round this all up the final command used to create the application can be seen below:
argocd app create hav1s-htmlapp \
  --repo https://github.com/hav1s/html-gitops.git \
  --path overlays/staging \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace staging \
  --project default
We had another error here (I can’t remember the name) but this error was resolved when we used the command “kustomize edit fix” which fixed the ‘kustomization.yaml’ files.
