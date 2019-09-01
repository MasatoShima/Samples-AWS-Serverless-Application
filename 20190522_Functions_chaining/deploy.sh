# Name: Masato Shima
# Created on: 2019/08/04

# Upload statemachine.yaml
aws s3 cp statemachine.yaml s3://mybucket-deploy/statemachine.yaml

# package
sam package \
 --template-file template.yaml \
 --s3-bucket mybucket-deploy \
 --output-template-file template-packaged.yaml \
 --profile default

# deploy
sam deploy \
 --template-file template-packaged.yaml \
 --stack-name Samples-AWS-Serverless-Application \
 --profile default \
 --region ap-northeast-1 \
 --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM

# End
