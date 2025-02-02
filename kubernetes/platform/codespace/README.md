
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install coder-db bitnami/postgresql \
    --namespace coder \
    --set auth.username=coder \
    --set auth.password=coder \
    --set auth.database=coder \
    --set persistence.size=10Gi
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/he/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/he/.kube/config
"bitnami" has been added to your repositories
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/he/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/he/.kube/config
NAME: coder-db
LAST DEPLOYED: Sat Jan 18 20:10:35 2025
NAMESPACE: coder
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: postgresql
CHART VERSION: 16.4.3
APP VERSION: 17.2.0

Did you know there are enterprise versions of the Bitnami catalog? For enhanced secure software supply chain features, unlimited pulls from Docker, LTS support, or application customization, see Bitnami Premium or Tanzu Application Catalog. See https://www.arrow.com/globalecs/na/vendors/bitnami for more information.

** Please be patient while the chart is being deployed **

PostgreSQL can be accessed via port 5432 on the following DNS names from within your cluster:

    coder-db-postgresql.coder.svc.cluster.local - Read/Write connection

To get the password for "postgres" run:

    export POSTGRES_ADMIN_PASSWORD=$(kubectl get secret --namespace coder coder-db-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

To get the password for "coder" run:

    export POSTGRES_PASSWORD=$(kubectl get secret --namespace coder coder-db-postgresql -o jsonpath="{.data.password}" | base64 -d)

To connect to your database run the following command:

    kubectl run coder-db-postgresql-client --rm --tty -i --restart='Never' --namespace coder --image docker.io/bitnami/postgresql:17.2.0-debian-12-r6 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host coder-db-postgresql -U coder -d coder -p 5432

    > NOTE: If you access the container using bash, make sure that you execute "/opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash" in order to avoid the error "psql: local user with ID 1001} does not exist"

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace coder svc/coder-db-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U coder -d coder -p 5432

WARNING: The configured password will be ignored on new installation in case when previous PostgreSQL release was deleted through the helm command. In that case, old PVC will have an old password, and setting it through helm won't take effect. Deleting persistent volumes (PVs) will solve the issue.

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - primary.resources
  - readReplicas.resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
```
