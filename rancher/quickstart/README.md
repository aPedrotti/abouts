# Rancher 

## Via Vagrant
```bash
vagrant up
```

## Via Docker
```
docker run -d --restart=unless-stopped -p 8081:80 -p 4444:443 --privileged rancher/rancher
curl localhost:4444
```