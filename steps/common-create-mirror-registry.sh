source ./tools/format.sh

mirror-registries-config.sh
#!/bin/bash
cat > registries-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: mirror-registries
  namespace: multicluster-engine
  labels:
    app: assisted-service
data:
  ca-bundle.crt: |
$(sed 's/^/        /' fullchain.pem)

registries.conf:
$(sed 's/^/        /' registries.conf)

EOF

oc get agentserviceconfig agent -o yaml --show-managed-fields=false > agent-service.yaml.tmp

sed '/spec:/a\ \ mirrorRegistryRef:\n    name: mirror-registries' agent-service.yaml.tmp > agent-service.yaml
Apply generated yaml files
oc apply -f registry.yaml
oc apply -f agent-service.yaml
