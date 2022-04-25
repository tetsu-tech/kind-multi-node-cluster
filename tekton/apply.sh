# Create bash/shell variables
REGISTRY_SERVER=https://index.docker.io/v1/ # Replace with your registry server
REGISTRY_USER=<REGISTRY_USER> # Replace with your docker hub username or registry username
REGISTRY_PASS=<REGISTRY_PASS> # Note that using passwords in shell is not secure. Replace with your docker hub password or registry password
REGISTRY_EMAIL=<REGISTRY_EMAIL> # Replace with your docker hub email or registry email
REGISTRY_AUTH=$(echo -n "$REGISTRY_USER:$REGISTRY_PASS" | base64)

echo $REGISTRY_SERVER
echo $REGISTRY_USER
echo $REGISTRY_PASS
echo $REGISTRY_EMAIL
echo $REGISTRY_AUTH

# Replace the values of the REGISTRY_ placeholders with the actual values of the variables in the docker-secret.yaml file
sed -i '' "s|REGISTRY_SERVER|$REGISTRY_SERVER|g" ./tekton/docker-secret.yaml
sed -i '' "s|REGISTRY_USER|$REGISTRY_USER|g" ./tekton/docker-secret.yaml
sed -i '' "s|REGISTRY_PASS|$REGISTRY_PASS|g" ./tekton/docker-secret.yaml
sed -i '' "s|REGISTRY_EMAIL|$REGISTRY_EMAIL|g" ./tekton/docker-secret.yaml

# Create the secret
kubectl apply -f ./tekton/docker-secret.yaml
