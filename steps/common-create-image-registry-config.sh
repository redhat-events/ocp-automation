oc get pod -n openshift-image-registry -l docker-registry=default
/usr/bin/cat <<'EOYAML' | oc apply -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: image-registry-storage
  namespace: openshift-image-registry
  annotations:
    imageregistry.openshift.io: 'true'
  finalizers:
    - kubernetes.io/pvc-protection
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  volumeMode: Filesystem
EOYAML
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"pvc":{"claim":"image-registry-storage"}}}}'
oc patch configs.imageregistry.operator.openshift.io/cluster --type=merge --patch '{"spec":{"rolloutStrategy":"Recreate","replicas":1}}'
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Managed"}}'
oc get route -n openshift-image-registry
oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'
# TODO: Wait for route
