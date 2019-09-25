@rem Name: Masato Shima
@rem Created on: 2019/09/02

@rem Upload statemachine.yaml
aws s3 cp ^
  ./20190522_Functions_chaining/statemachine.yaml ^
  s3://mybucket-deploy/statemachine_chaining.yaml ^
  --profile private

@rem Upload eventpattern.json
aws s3 cp ^
  ./20190522_Functions_chaining/eventpattern.json ^
  s3://mybucket-deploy/eventpattern_chaining.json ^
  --profile private

aws s3 cp ^
  ./20190924_Activity_send_message/eventpattern.json ^
  s3://mybucket-deploy/eventpattern_send_message.json ^
  --profile private

@rem render template.yaml
python ./Tools/render_template.py -t ./template.yaml.tpl

@rem package
sam package ^
 --template-file template.yaml ^
 --s3-bucket mybucket-deploy ^
 --output-template-file template-packaged.yaml ^
 --profile private

@rem deploy
sam deploy ^
 --template-file template-packaged.yaml ^
 --stack-name Samples-AWS-Serverless-Application ^
 --profile private ^
 --region ap-northeast-1 ^
 --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM

@rem End
