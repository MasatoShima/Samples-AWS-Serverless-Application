# Name: Masato Shima
# Created on: 2019/08/04

# Upload statemachine.yaml
aws s3 cp \
  ./20190522_Functions_chaining/statemachine.yaml \
  s3://mybucket-deploy/statemachine_chaining.yaml \
  --profile private

# package
sam package \
 --template-file template.yaml \
 --s3-bucket mybucket-deploy \
 --output-template-file template-packaged.yaml \
 --profile private

# deploy
sam deploy \
 --template-file template-packaged.yaml \
 --stack-name Samples-AWS-Serverless-Application \
 --profile private \
 --region ap-northeast-1 \
 --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM

# End
