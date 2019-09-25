AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: Sample

# More info about Globals:
# https://github.com/awslabs/serverless-application-model/blob/master/docs/globals.rst
# More info about Env Vars:
# https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#environment-object
Globals:
    Function:
        Runtime: python3.6
        MemorySize: 128
        Timeout: 900
        Environment:
            Variables:
                TZ: Asia/Tokyo
        Layers:
            - !Ref Layer

Resources:

    # **************************************************
    # ----- Lambda Functions
    # **************************************************
    FunctionGet:
        # More info about Function Resource:
        # https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction
        Type: AWS::Serverless::Function
        Properties:
            FunctionName: Lambda_StepFunctions_Sample_Get
            Handler: Lambda_StepFunctions_Sample_Get.lambda_handler
            CodeUri: 20190522_Functions_chaining/001_Get/
            Description: |
                For Sample
                (Get file from S3 and return its contents as return value)
            Role: !GetAtt RoleForLambda.Arn

    FunctionCal:
        # More info about Function Resource:
        # https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction
        Type: AWS::Serverless::Function
        Properties:
            FunctionName: Lambda_StepFunctions_Sample_Cal
            Handler: Lambda_StepFunctions_Sample_Cal.lambda_handler
            CodeUri: 20190522_Functions_chaining/002_Cal/
            Description: |
                For Sample
                (Refers to the event object and squares the numerical data stored in the specified position)
            Role: !GetAtt RoleForLambda.Arn

    FunctionCreateRamdomValue:
        # More info about Function Resource:
        # https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction
        Type: AWS::Serverless::Function
        Properties:
            FunctionName: Lambda_StepFunctions_Sample_CreateRandomValues
            Handler: create_ramdom_values.lambda_handler
            CodeUri: 20190901_Functions_fun_in_out/001_Create_random_values
            Description: |
                For Sample
                (********)
            Role: !GetAtt RoleForLambda.Arn

    # **************************************************
    # ----- CloudWatch Event
    # **************************************************
    # About AWS resource events rule
    # https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html
    # https://docs.aws.amazon.com/eventbridge/latest/APIReference/API_PutTargets.html
    RuleFunctionChaining:
        Type: AWS::Events::Rule
        Properties:
            Name: StepFunctions_Sample_Functions_chaining
            Description: From S3 object put event, To execute StepFunctions StateMachine
            EventPattern:
                Fn::Transform:
                    Name: AWS::Include
                    Parameters:
                        Location:
                            Fn::Sub: s3://mybucket-deploy/eventpattern_chaining.json
            RoleArn: !GetAtt RoleForCloudWatchevent.Arn
            State: ENABLED
            Targets:
                - Id: FunctionChaining
                  Arn: !Ref StateMachineFunctionChaining
                  RoleArn: !GetAtt RoleForCloudWatchevent.Arn

    RuleSendMessgae:
        Type: AWS::Events::Rule
        Properties:
            Name: StepFunctions_Sample_Activity_Send_Message
            Description: From S3 object put event, To execute StepFunctions StateMachine
            EventPattern:
                Fn::Transform:
                    Name: AWS::Include
                    Parameters:
                        Location:
                            Fn::Sub: s3://mybucket-deploy/eventpattern_send_message.json
            RoleArn: !GetAtt RoleForCloudWatchevent.Arn
            State: ENABLED
            Targets:
                - Id: ActivitySendMessgae
                  Arn: !Ref StateMachineActivitySendMessage
                  RoleArn: !GetAtt RoleForCloudWatchevent.Arn

    # **************************************************
    # ----- Lambda Layer
    # **************************************************
    Layer:
        Type: AWS::Lambda::LayerVersion
        Properties:
            LayerName: LambdaLayer_Lambda_StepFunctions_Sample
            CompatibleRuntimes:
                - python3.6
                - python3.7
            Content:
                S3Bucket: mybucket-deploy
                S3Key: Layer.zip
            Description: Lambda Layer for "Samples-AWS-Serverless-Application"

    # **************************************************
    # ----- IAM
    # **************************************************
    RoleForLambda:
        Type: AWS::IAM::Role
        Properties:
            RoleName: RoleForLambda-Lambda-StepFunctions-Sample
            AssumeRolePolicyDocument:
                Version: 2012-10-17
                Statement:
                    -   Action:
                            - "sts:AssumeRole"
                        Effect: "Allow"
                        Principal:
                            Service:
                                - "lambda.amazonaws.com"

    RoleForStepFunctions:
        Type: AWS::IAM::Role
        Properties:
            RoleName: RoleForStepFunctions-Lambda-StepFunctions-Sample
            AssumeRolePolicyDocument:
                Version: 2012-10-17
                Statement:
                    -   Action:
                            - "sts:AssumeRole"
                        Effect: "Allow"
                        Principal:
                            Service:
                                - "states.amazonaws.com"

    RoleForCloudWatchevent:
        Type: AWS::IAM::Role
        Properties:
            RoleName: RoleForCloudWatchEvent-Lambda-StepFunctions-Sample
            AssumeRolePolicyDocument:
                Version: 2012-10-17
                Statement:
                    -   Action:
                            - "sts:AssumeRole"
                        Effect: "Allow"
                        Principal:
                            Service:
                                - "events.amazonaws.com"

    PolicyForLambda:
        Type: AWS::IAM::Policy
        Properties:
            PolicyName: PolicyForLambda-Lambda-StepFunctions-Sample
            PolicyDocument:
                Version: 2012-10-17
                Statement:
                    - "Action":
                        - "s3:GetObject"
                        - "s3:PutObject"
                      "Effect": "Allow"
                      "Resource": "*"
            Roles:
                - !Ref RoleForLambda

    PolicyForStepFunctions:
        Type: AWS::IAM::Policy
        Properties:
            PolicyName: PolicyForStepFunctions-Lambda-StepFunctions-Sample
            PolicyDocument:
                Version: 2012-10-17
                Statement:
                    - "Action":
                        - "lambda:InvokeFunction"
                        - "sqs:*"
                      "Effect": "Allow"
                      "Resource": "*"
            Roles:
                - !Ref RoleForStepFunctions

    PolicyForCloudWatchevent:
        Type: AWS::IAM::Policy
        Properties:
            PolicyName: PolicyForCloudWatchEvent-Lambda-StepFunctions-Sample
            PolicyDocument:
                Version: 2012-10-17
                Statement:
                    - "Action":
                        - "states:StartExecution"
                      "Effect": "Allow"
                      "Resource": "*"
            Roles:
                - !Ref RoleForCloudWatchevent

    # **************************************************
    # ----- S3
    # **************************************************
    Bucket:
        Type: AWS::S3::Bucket
        Properties:
            BucketName: !Sub lambda-stepfunctions-sample-${AWS::AccountId}

    # **************************************************
    # ----- SQS Queues
    # **************************************************
    Queue:
        Type: AWS::SQS::Queue
        Properties:
            QueueName: !Sub lambda-stepfunctions-sample-${AWS::AccountId}

    # **************************************************
    # ----- Step Functions
    # **************************************************
    StateMachineFunctionChaining:
        Type: AWS::StepFunctions::StateMachine
        Properties:
            StateMachineName: Sample_StateMachine_Function_Chaining
            Fn::Transform:
                Name: AWS::Include
                Parameters:
                    Location:
                        Fn::Sub: s3://mybucket-deploy/statemachine_chaining.yaml
            RoleArn: !GetAtt RoleForStepFunctions.Arn

    StateMachineActivitySendMessage:
        Type: AWS::StepFunctions::StateMachine
        Properties:
            StateMachineName: Sample_StateMachine_Activity_Send_Message
            DefinitionString:
                Fn::Sub: |-
                    {% filter indent(20, False) %}
                    {%- include "20190924_Activity_send_message/statemachine.json" -%}
                    {%- endfilter %}
            RoleArn: !GetAtt RoleForStepFunctions.Arn

# End
