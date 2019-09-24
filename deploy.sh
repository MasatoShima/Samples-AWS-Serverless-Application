# Name: Masato Shima
# Created on: 2019/08/04

# Upload statemachine.yaml
aws s3 cp \
  ./20190522_Functions_chaining/statemachine.yaml \
  s3://mybucket-deploy/statemachine_chaining.yaml \
  --profile private

aws s3 cp \
  ./20190924_Activity_send_message/statemachine.yaml \
  s3://mybucket-deploy/statemachine_send_message.yaml \
  --profile private

# Upload eventpattern.json
aws s3 cp \
  ./20190522_Functions_chaining/eventpattern.json \
  s3://mybucket-deploy/eventpattern_chaining.json \
  --profile private

aws s3 cp \
  ./20190924_Activity_send_message/eventpattern.json \
  s3://mybucket-deploy/eventpattern_send_message.json \
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
