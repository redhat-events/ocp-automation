source ./tools/format.sh
# https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/installing_on_bare_metal/preparing-to-install-on-bare-metal#nw-sriov-dual-nic-con_preparing-to-install-on-bare-metal
# https://github.com/pmalan/openshift-tricks/blob/main/Post-Install/networking/Recovering_from_bad_NNCP.adoc
__ "Add vlans to the cluster" 2
INTERFACE=bond0
NAMESPACE=demo

__ "Create demo namespace" 3
cmd "oc project $NAMESPACE &>/dev/null || oc new-project $NAMESPACE &>/dev/null"

__ "Create cnv-vlan template" 3
cmd oc apply -f templates/networking/vlan.cnv-bridge.config.template
__ "Create ovn-vlan template" 3
cmd oc apply -f templates/networking/vlan.ovn-bridge.config.template

__ "Create cnv-vlan instance" 3
VLAN=777
cmd "oc process vlan-cnv-template -n $NAMESPACE -p VLAN=$VLAN -p INTERFACE=$INTERFACE | oc apply -f -"

__ "Create ovn-vlan instance on shared bridge" 3
VLAN=999
__ "Create shared bridge" 4
cmd "oc process ovs-bridge-vlan-template -p INTERFACE=$INTERFACE -o yaml | oc apply -f -"
__ "Create vlan network" 4
cmd "oc process vlan-ovs-network-template -n $NAMESPACE -p VLAN=$VLAN -p BRIDGE=br-${INTERFACE}-vlan -p NAMESPACE=$NAMESPACE -o yaml | oc apply -f -"
