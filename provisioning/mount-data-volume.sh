#!/bin/bash

devpath=$(readlink -f /dev/sdh)

sudo file -s $devpath | grep -q ext4
if [[ 1 == $? && -b $devpath ]]; then
  sudo mkfs -t ext4 $devpath
fi

#sudo groupadd mongodb
#sudo groupadd -f mongodb
#sudo id -u mongouser &>/dev/null || sudo useradd mongouser
#sudo usermod -a -G mongodb mongouser

sudo mkdir /mongodata
#sudo chown -R  mongouser:mongodb /mongodata
sudo chmod -R 0775 /mongodata

echo "$devpath /mongodata ext4 defaults,nofail,noatime,nodiratime,barrier=0,data=writeback 0 2" | sudo tee -a /etc/fstab > /dev/null
sudo mount /mongodata

sudo mkdir -p /mongodata/var/lib/mongodb
sudo mkdir -p /mongodata/var/log/mongodb/
sudo touch /mongodata/var/log/mongodb/mongod.log

#sudo chown -R  mongouser:mongodb /mongodata
#sudo chmod ug+w /mongodata/var/log/mongodb/mongod.log
#sudo chmod -R ug+rw /mongodata/
#sudo chmod -R oug+rw /mongodata/var/lib/
#sudo chmod -R oug+rw /mongodata/var/log/

# TODO: /etc/rc3.d/S99local to maintain on reboot
echo deadline | sudo tee /sys/block/$(basename "$devpath")/queue/scheduler
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled