# Mongo-cloudformation-Graviton-deployment
This repo contain an end to end cloudformation template such that it can deploy a complete mongo cluster with graviton boxes

# Small brief about things which are used here
- **Cloudformation**: In AWS, CloudFormation is a service that helps you model and provision your cloud resources in a declarative and automated way.
- **Mongo Router**: The MongoDB Router (known as mongos) is a routing service that directs client queries to the appropriate shard(s) in a sharded MongoDB cluster.
- **Mongo config server**: A MongoDB Config Server is the brain of a sharded cluster, holding metadata that tells routers (mongos) where data lives and how it’s split across shards.
- **Mongo Shard**: A Shard in MongoDB is a database partition that stores a subset of the data in a sharded cluster.
- **primary and secondary instances**: ahh defination better see this flow 
```
Writes → Primary → Replicates oplog → Secondary1, Secondary2
Reads  → (default) Primary
        → (optional) Secondary (with read preference)
```

# Linux script explained:
the router and config are staright forward where you don't need anything specifc to understand but shard hmm... lets conver
- Shard
```
 #!/bin/bash
echo "Configuring Shard Node"
sudo -i

# Create mount points
mkdir -p /mnt/mongodb-data/journal
mkdir -p /mnt/mongodb-data/data
mkdir -p /var/log/mongodb
mkdir -p /etc/ssl/mongodb/

# Format disks (only if they are new and not pre-formatted)
if ! lsblk -f | grep -q /dev/nvme1n1; then
mkfs.ext4 /dev/nvme1n1
fi
if ! lsblk -f | grep -q /dev/nvme2n1 ; then
mkfs.ext4 /dev/nvme2n1
fi

# note: this is always true only and only for fresh deployment if you already have data then identify better way to mount it and validate manually first

# Mount the disks
mount /dev/nvme2n1 /mnt/mongodb-data/journal
mount /dev/nvme1n1 /mnt/mongodb-data/data

# Set correct ownership and permissions
chown -R mongodb:mongodb /mnt/mongodb-data
chown -R mongodb:mongodb /var/log/mongodb
chown -R mongodb:mongodb /etc/ssl/mongodb/
chmod 755 /mnt/mongodb-data/data
chmod 755 /mnt/mongodb-data/journal
chmod 755 /var/log/mongodb


# Persist mounts in /etc/fstab
echo "/dev/nvme2n1 /mnt/mongodb-data/journal ext4 defaults,noatime 0 0" >> /etc/fstab
echo "/dev/nvme1n1 /mnt/mongodb-data/data ext4 defaults,noatime 0 0" >> /etc/fstab

if [ ! -f /var/log/first_boot_done ]; then
sudo reboot
fi
```

# Conclusion
this script comes very handy when you are trying to bring mongo cluster up with any VM type and then add it to existing cluster 
