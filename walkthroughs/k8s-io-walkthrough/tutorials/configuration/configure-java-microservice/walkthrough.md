# configure-java-microservice

## Getting Started

https://openliberty.io/guides/microprofile-config.html#try-what-youll-build
https://github.com/OpenLiberty/guide-kubernetes-microprofile-config

## Deploying the microservices

Now you need to navigate into the project directory that has been provided for you. This contains the implementation of the MicroProfile microservices, configuration for the MicroProfile runtime, and Kubernetes configuration.

`cd guide-kubernetes-microprofile-config/start/`

You will notice there is a 'finish' directory. This contains the finished code for this tutorial for reference.

The two microservices you will deploy are called 'system' and 'inventory'. The system microservice returns JVM properties of the container it is running in. The inventory microservice adds the properties from the system microservice into the inventory. This demonstrates how communication can be achieved between two microservices in separate pods inside a Kubernetes cluster. To build the applications with Maven, run the following commands one after the other:

`mvn clean package`

Next, run the docker build commands to build container images for your application:

```bash
docker build -t system:1.0-SNAPSHOT system/.
docker build -t inventory:1.0-SNAPSHOT inventory/.
```

Once the services have been built, you need to deploy them to Kubernetes.

`kubectl apply -f kubernetes.yaml`

The two commands below will check the status of the pods and check when they are in a ready state. This is done by providing the command with the labels for the pod such as inventory. Issue the following commands to check the status of your microservices:

`kubectl wait --for=condition=ready pod -l app=inventory`

`kubectl wait --for=condition=ready pod -l app=system`

Once you see the output condition met from each of the above commands it means your microservices are ready to receive requests.

Now that your microservices are deployed and running with the Ready status you are ready to send some requests.

Next, you'll use curl to make an HTTP GET request to the 'system' service. The service is secured with a user id and password that is passed in the request.

`minikube service system-service --url`
`minikube service inventory-service --url`

`curl -u bob:bobpwd http://< minikube service url >/system/properties`

You should see a response that will show you the JVM system properties of the running container.

Similarly, use the following curl command to call the inventory service:

`curl http://< minikube service url >/inventory/systems/system-service`

The inventory service will call the system service and store the response data in the inventory service before returning the result.

In this tutorial, you're going to use a Kubernetes ConfigMap to modify the `X-App-Name:` response header. Take a look at their current values by running the following curl command:

`curl -# -I -u bob:bobpwd -D - http://< minikube service url >/system/properties | grep -i ^X-App-Name:`

## Modifying the System Microservice

The system service is hardcoded to have system as the app name. To make this configurable, you'll add the `appName` member and code to set the `X-App-Name` to the `/guide-kubernetes-microprofile-config/start/system/src/main/java/system/SystemResource.java` file. Click on the link above to open the file and then use the Katacode text editor to replace the existing code with the following:

```bash
// CDI
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.GET;
// JAX-RS
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.eclipse.microprofile.config.inject.ConfigProperty;

@RequestScoped
@Path("/properties")
public class SystemResource {

  @Inject
  @ConfigProperty(name = "APP_NAME")
  private String appName;

  @Inject
  @ConfigProperty(name = "HOSTNAME")
  private String hostname;

  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public Response getProperties() {
    return Response.ok(System.getProperties())
      .header("X-Pod-Name", hostname)
      .header("X-App-Name", appName)
      .build();
  }
}
```

These changes use MicroProfile Config and CDI to inject the value of an environment variable called `APP_NAME` into the `appName` member of the SystemResource class. MicroProfile Config supports a number of config sources from which to receive configuration, including environment variables.

## Modifying the Inventory Microservice

The inventory service is hardcoded to use bob and bobpwd as the credentials to authenticate against the system service. You’ll make these credentials configurable using a Kubernetes Secret. In the Katacoda text editor, open the file by clicking on the following link `/guide-kubernetes-microprofile-config/start/inventory/src/main/java/inventory/client/SystemClient.java` and replace the two lines under `// Basic Auth Credentials` with the following

```bash
// Basic Auth Credentials
  @Inject
  @ConfigProperty(name = "SYSTEM_APP_USERNAME")
  private String username;

  @Inject
  @ConfigProperty(name = "SYSTEM_APP_PASSWORD")
  private String password;
```

These changes use MicroProfile Config and CDI to inject the value of the environment variables `SYSTEM_APP_USERNAME` and `SYSTEM_APP_PASSWORD` into the SystemClient class.

## Modifying the Inventory Microservice

The inventory service is hardcoded to use bob and bobpwd as the credentials to authenticate against the system service. You’ll make these credentials configurable using a Kubernetes Secret. In the Katacoda text editor, open the file by clicking on the following link `/guide-kubernetes-microprofile-config/start/inventory/src/main/java/inventory/client/SystemClient.java` and replace the two lines under // Basic Auth Credentials with the following

```bash
// Basic Auth Credentials
  @Inject
  @ConfigProperty(name = "SYSTEM_APP_USERNAME")
  private String username;

  @Inject
  @ConfigProperty(name = "SYSTEM_APP_PASSWORD")
  private String password;
```

These changes use MicroProfile Config and CDI to inject the value of the environment variables `SYSTEM_APP_USERNAME` and `SYSTEM_APP_PASSWORD` into the SystemClient class.

## Creating a ConfigMap and Secret

There are several ways to configure an environment variable in containers. You are going to use a Kubernetes ConfigMap and Kubernetes secret to set these values. These are resources provided by Kubernetes that are used as a way to provide configuration values to your containers. A benefit is that they can be re-used across multiple containers, including being assigned to different environment variables for the different containers.

Create a ConfigMap to configure the application name with the following kubectl command:

`kubectl create configmap sys-app-name --from-literal name=my-system`

This command deploys a ConfigMap named sys-app-name to your cluster. It has a key called name with a value of my-system. The `--from-literal flag` allows you to specify individual key-value pairs to store in this ConfigMap. Other available options, such as `--from-file` and `--from-env-file`, provide more versatility as to how to configure. Details about these options can be found in the Kubernetes CLI documentation here https://kubernetes.io/docs/concepts/configuration/configmap/.

Create a secret to configure the credentials that the inventory service will use to authenticate against system service with the following kubectl command:

`kubectl create secret generic sys-app-credentials --from-literal username=bob --from-literal password=bobpwd`

This command looks very similar to the command to create a ConfigMap, one difference is the word generic. It means that you’re creating a secret that is generic, which means it is not a specialized type of secret. There are different types of secrets, such as secrets to store Docker credentials and secrets to store public/private key pairs.

A secret is similar to a ConfigMap, except a secret is used for sensitive information such as credentials. One of the main differences is that you have to explicitly tell kubectl to show you the contents of a secret. Additionally, when it does show you the information, it only shows you a Base64 encoded version so that a casual onlooker can't accidentally see any sensitive data. secrets don’t provide any encryption by default, that is something you’ll either need to do yourself or find an alternate option to configure.

## Updating Kubernetes resources

You will now update your Kubernetes deployment to set the environment variables in your containers, based on the values configured in the ConfigMap and Secret. Edit the kubernetes.yaml file (located in the start directory). This file defines the Kubernetes deployment. Note the valueFrom field. This specifies the value of an environment variable, and can be set from various sources. Sources include a ConfigMap, a Secret, and information about the cluster. In this example `configMapKeyRef` sets the key name with the value of the ConfigMap `sys-app-name`. Similarly, secretKeyRef sets the keys username and password with values from the Secret `sys-app-credentials`.

Open the `/guide-kubernetes-microprofile-config/start/kubernetes.yaml` file by clicking on the above link and replace the contents with the following:

```Bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: system-deployment
  labels:
    app: system
spec:
  selector:
    matchLabels:
      app: system
  template:
    metadata:
      labels:
        app: system
    spec:
      containers:
      - name: system-container
        image: system:1.0-SNAPSHOT
        ports:
        - containerPort: 9080
        # Set the APP_NAME environment variable
        env:
        - name: APP_NAME
          valueFrom:
            configMapKeyRef:
              name: sys-app-name
              key: name
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inventory-deployment
  labels:
    app: inventory
spec:
  selector:
    matchLabels:
      app: inventory
  template:
    metadata:
      labels:
        app: inventory
    spec:
      containers:
      - name: inventory-container
        image: inventory:1.0-SNAPSHOT
        ports:
        - containerPort: 9080
        # Set the SYSTEM_APP_USERNAME and SYSTEM_APP_PASSWORD environment variables
        env:
        - name: SYSTEM_APP_USERNAME
          valueFrom:
            secretKeyRef:
              name: sys-app-credentials
              key: username
        - name: SYSTEM_APP_PASSWORD
          valueFrom:
            secretKeyRef:
              name: sys-app-credentials
              key: password
---
apiVersion: v1
kind: Service
metadata:
  name: system-service
spec:
  type: NodePort
  selector:
    app: system
  ports:
  - protocol: TCP
    port: 9080
    targetPort: 9080
    nodePort: 31000
---
apiVersion: v1
kind: Service
metadata:
  name: inventory-service
spec:
  type: NodePort
  selector:
    app: inventory
  ports:
  - protocol: TCP
    port: 9080
    targetPort: 9080
    nodePort: 32000
```

Deploying your changes
You now need rebuild and redeploy the applications for your changes to take effect. Rebuild the application using the following commands, making sure you're in the start directory:

`mvn package -pl system`

`mvn package -pl inventory`

Now you need to delete your old Kubernetes deployment then deploy your updated deployment by issuing the following commands:

`kubectl replace --force -f kubernetes.yaml`

You should see the following output from the commands:

```bash
$ kubectl replace --force -f kubernetes.yaml
deployment.apps "system-deployment" deleted
deployment.apps "inventory-deployment" deleted
service "system-service" deleted
service "inventory-service" deleted
deployment.apps/system-deployment replaced
deployment.apps/inventory-deployment replaced
service/system-service replaced
service/inventory-service replaced
```

Check the status of the pods for the services with:

`kubectl get --watch pods`

You should eventually see the status of Ready for the two services. Press Ctrl-C to exit the terminal command.

Call the updated system service and check the headers using the curl command:

`curl -u bob:bobpwd -D - http://< minikube service url >:31000/system/properties -o /dev/null`

You should see that the response X-App-Name header has changed from system to my-system​.

Verify that inventory service is now using the Kubernetes Secret for the credentials by making the following curl request:

`curl http://< minikube service url >:32000/inventory/systems/system-service`

If the request fails, check you've configured the Secret correctly.