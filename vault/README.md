# Uncomplicating Vault

## TL;DR

You will find information about implementing and managing Hashicorp Vault service as a study path from Hashicorp Learn.

## About

It is initially forked from @badtuxx nomad training, however it was main focused to create labs to implement Hashicorp Vault capabilities.

You would be able to spin-up two differnt kind of environments to test:

- Virtual machine (with Vagrant + Nomad)

- Kubernetes Cluster (with Kind)

The nomad journey was initially taken from #LinuxTips ["Nomad + Vault"](https://www.youtube.com/playlist?list=PLf-O3X2-mxDlBQW_1kb_RT6LcYX_XwyAG) playlist, addapting local environment with Vagrant and agreagating more functions of Hashicorp Vault with [Vault Learn](https://learn.hashicorp.com/vault) documentation

All these runs in dev mode (in-memory). If you would like to persist, check full path (days) for Nomad and vault-run-prod.md.

You can check vault-commands.md for further vault cli references

## Requirements

- kind [https://kind.sigs.k8s.io/docs/user/quick-start/]
- kubectl []
- virtualbox []
- vagrant []

## Run VM

```bash
vagrant up

vagrant ssh
```

## Start your Nomad Server / Client

```bash
sudo nomad agent -dev -bind 0.0.0.0 -log-level INFO &
# Or if you would like to place some custom config 
sudo nomad agent -dev -config="/etc/nomad.d/nomad.hcl" -log-level INFO &
```

### Main Nomad commands

```bash
nomad node status
nomad server members

# To generate a sample of job / deploy - example.nomad
nomad job init 

nomad job run <file.nomad>
nomad job status
```

## Vault start

```bash
#export VAULT_ADDR='http://10.0.2.15:8200'
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_DEV_ROOT_TOKEN_ID=naosei
vault server -dev -dev-listen-address :8200 -dev-root-token-id "${VAULT_DEV_ROOT_TOKEN_ID}" &
# Grab unseal key and add 
export VAULT_UNSEAL_KEY="....."

# About Sealing 
#https://www.vaultproject.io/docs/concepts/seal
# Patterns for unsealing 
#https://developer.hashicorp.com/vault/tutorials/recommended-patterns/pattern-unseal?in=vault%2Frecommended-patterns

```

## Integrate Vault with Nomad

[https://www.nomadproject.io/docs/configuration/vault]

```bash
# Get ta default policy and write it in vault's db
curl https://nomadproject.io/data/vault/nomad-server-policy.hcl -O -s -L
vault policy write nomad-server nomad-server-policy-vault.hcl
# Create and apply a Vault role for the token
cat <<EOF > nomad-cluster-role.json
{
  "disallowed_policies": "nomad-server",
  "allowed_policies": "access-tables",
  "token_explicit_max_ttl": 0,
  "name": "nomad-cluster",
  "orphan": true,
  "token_period": 259200,
  "renewable": true
}
EOF
# Publish 
vault write /auth/token/roles/nomad-cluster @nomad-cluster-role.json
#Generate a token
vault token create -policy nomad-server -period 72h -orphan 
# orphan means that it does not take into consideration parents periods policy
# take note token to add to nomad server - vault stanza
```

### Configuring Nomad Servers

[https://www.nomadproject.io/docs/configuration/vault]

```bash
# Add vault stanza to nomad config 
cat <<EOF >> /etc/nomad.d/nomad.hcl
vault {
    enabled = true
    address = "http://10.0.2.15:8200"
    task_token_ttl = "1h"
    create_from_role = "nomad-cluster¨
    token = "<< FILL HERE WITH GEN TOKEN >>"
}
EOF
# Restart the service or stop and run again if using dev mode
systemctl restart nomad.service
```

### Configuring Nomad Clients

> if you have it

```bash
cat <<EOF >> /etc/nomad.d/nomad.hcl
vault {
    enabled = true
    address = "http://10.0.2.15:8200"
}
EOF

systemctl restart nomad.service
```

## Configuring Dynamic Database

```bash
# Enables database in a path
vault secrets enable -path dbs database

# Deploy Mysql Application
nomad run vault-secrets-database/0-mysql.nomad

# Config Connection
vault write dbs/config/my-mysql-connection @vault-secrets-database/1-connection-mysql.json

# Configure Vault Access Management and TTL
vault write dbs/roles/my-mysql-role @vault-secrets-database/2-accessdb-role-mysql.json

# Configure policy to be able to read credentials
vault policy write my-mysql-policy-read vault-secrets-database/3-access-tables-policy-mysql.hcl

# Confirms credential reading
vault read dbs/creds/my-mysql-role 

# Deploy the app to comunicate:
nomad run vault-secrets-database/app.nomad #currently not working - "Vault not enabled and Vault policies requested" 

## For Postgres - not being able to read creds 
nomad run vault-secrets-database/0-postgres.nomad
vault write dbs/config/my-postgres-connection @vault-secrets-database/1-connection-postgres.json
vault write dbs/roles/my-postgres-role @vault-secrets-database/2-accessdb-role-postgres.json
#or using sql file for statement
vault write dbs/roles/my-postgres-role db_name=my-postgres-connection allowed_roles=my-postgres-role creation_statements=@vault-secrets-database/2-accessdb-role-postgres.sql default_tl=1h max_ttl=24h
vault policy write my-postgres-policy-read vault-secrets-database/3-access-tables-policy-pgsql.hcl
vault read dbs/creds/my-postgres-role
```

## Vault in Kubernetes

You can deploy Vault via helm chart as following documentations 

### Deploy Environment

- Spin up a cluster using kind [kind/readme.md]

- Add hashicorp repository

`helm repo add hashicorp https://helm.releases.hashicorp.com`

- Deploy Vault

*Check kubernetes matrix versions at [https://developer.hashicorp.com/vault/docs/platform/k8s/helm]*

`helm install vault hashicorp/vault`

Vault will be deployed, but not initialized (sealed);

`vault operator init`

Save the unseal keys and root token

`vault operator unseal`

and paste one of the keys ... repeat 3x (threashold)

`vault login`

...and use your root token

### Integrate kubernetes Secrets with vault

How to integrate vault with kubernetes cluster via External Secrets Operator

Documentation: [https://external-secrets.io/v0.8.5/]

Operator Project: [https://github.com/external-secrets/external-secrets]

- create a kv in vault

`vault secrets enable -mount=my-passwords kv`

`vault kv put -mount=my-passwords my-data user=andre pass=passwrd`

- create a policy in vault to read this kv

`vault policy write my-policy policy-kv.hcl`

- create a token for this policy

`vault token create -policy=my-policy`

- create a generic secret in kubernetes for this token

`kubectl create secret generic my-vault-secret-token --from-literal=token=hvs.blablablablabla`

- create a clusterSecretStore (for External Secrets Operator)

`kubectl create -f cluster-secret-store-my-pass.yaml`

*Secret Store (namespaced) & Cluster Secret Store: How do I access my Secret inside Vault (or other provider)*

- create your external secret ref

`kubectl create -f external-secret.yaml`

*External Secret - What secret do I want to access*


