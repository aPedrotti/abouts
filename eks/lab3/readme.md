## Task 1: Connect to the lab bastion host


## Task 2: Create an Amazon Kinesis Data Firehose delivery stream and configure Fluent Bit DaemonSet

export FIREHOSE_ROLE_ARN=FirehoseRoleArn S3_BUCKET_ARN=StreamBucketArn

aws firehose create-delivery-stream --delivery-stream-name eks-stream --delivery-stream-type DirectPut --s3-destination-configuration RoleARN=${FIREHOSE_ROLE_ARN},BucketARN=${S3_BUCKET_ARN},Prefix=eks/

kubectl create namespace fb

kubectl create sa fluent-bit -n fb

kubectl apply -f ~/scripts/task2/eks-fluent-bit-daemonset-rbac.yaml

kubectl apply -f ~/scripts/task2/eks-fluent-bit-configmap.yaml

kubectl apply -f ~/scripts/task2/eks-fluent-bit-daemonset.yaml

kubectl get daemonset fluentbit -n fb

kubectl logs ds/fluentbit -n fb



## Task 3: Deploy a sample application, collect log data, and analyze the data using Amazon Athena


kubectl apply -f ~/scripts/task3/eks-nginx-app.yaml

sh ~/scripts/task3/load-gen-eks.sh

- Abrir bucket e navegar por eks/YEAR/MONTH/DAY/HOUR/eks-stream-DATE-TIME-RANDOM_ALPHANUMERIC_CHARACTERS


CREATE EXTERNAL TABLE fluentbit_eks (
    log string
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://FireHoseBucket/eks/'


MSCK REPAIR TABLE fluentbit_eks;


## Task 4: Deploy and configure Amazon CloudWatch Container Insights

## Task 5: Deploy AWS X-Ray and review trace metrics