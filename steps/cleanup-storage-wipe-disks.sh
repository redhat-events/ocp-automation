source  ./tools/format.sh
__ "Cleanup Physical Disks" 3

_? "Remove partition information from node local storage disks (yes/no)" wipedisks no
if [ "$wipedisks" = "yes" ]; then
  wipeDiskCmd='for disk in $(ls -1 /dev/sd*); do sgdisk --zap-all $disk; wipefs -af $disk; dd if=/dev/zero of=$disk bs=1M count=10 conv=fdatasync; done'
  for node in $(oc get nodes -oname); do 
    __ "wipe disks on node: $node" 4
    cmd "oc debug $node -- chroot /host bash -c '$wipeDiskCmd'"
  done
else 
  __ "Skipping wipe disk" 4
fi

