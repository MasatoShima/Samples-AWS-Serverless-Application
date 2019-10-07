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

    FunctionCreateRandomValue:
        # More info about Function Resource:
        # https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#awsserverlessfunction
        Type: AWS::Serverless::Function
        Properties:
            FunctionName: Lambda_StepFunctions_Sample_CreateRandomValues
            Handler: create_random_values.lambda_handler
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
            RoleArn: !GetAtt RoleForCloudWatchEvent.Arn
            State: ENABLED
            Targets:
                - Id: FunctionChaining
                  Arn: !Ref StateMachineFunctionChaining
                  RoleArn: !GetAtt RoleForCloudWatchEvent.Arn

    RuleSendMessage:
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
            RoleArn: !GetAtt RoleForCloudWatchEvent.Arn
            State: ENABLED
            Targets:
                - Id: ActivitySendMessage
                  Arn: !Ref StateMachineActivitySendMessage
                  RoleArn: !GetAtt RoleForCloudWatchEvent.Arn

    RuleExecuteTask:
        Type: AWS::Events::Rule
        Properties:
            Name: StepFunctions_Sample_Activity_Execute_Task
            Description: From S3 object put event, To execute StepFunctions StateMachine
            EventPattern:
                Fn::Transform:
                    Name: AWS::Include
                    Parameters:
                        Location:
                            Fn::Sub: s3://mybucket-deploy/eventpattern_execute_task.json
            RoleArn: !GetAtt RoleForCloudWatchEvent.Arn
            State: ENABLED
            Targets:
                - Id: ActivityExecuteTask
                  Arn: !Ref StateMachineActivityExecuteTask
                  RoleArn: !GetAtt RoleForCloudWatchEvent.Arn

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

    RoleForECS:
        Type: AWS::IAM::Role
        Properties:
            RoleName: RoleForECS-Lambda-StepFunctions-Sample
            AssumeRolePolicyDocument:
                Version: 2012-10-17
                Statement:
                    -   Action:
                            - "sts:AssumeRole"
                        Effect: "Allow"
                        Principal:
                            Service:
                                - "ecs-tasks.amazonaws.com"

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

    RoleForCloudWatchEvent:
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
                        - "logs:*"
                        - "s3:GetObject"
                        - "s3:PutObject"
                      "Effect": "Allow"
                      "Resource": "*"
            Roles:
                - !Ref RoleForLambda

    PolicyForECS:
        Type: AWS::IAM::Policy
        Properties:
            PolicyName: PolicyForECS-Lambda-StepFunctions-Sample
            PolicyDocument:
                Version: 2012-10-17
                Statement:
                    - "Action":
                        - "logs:*"
                        - "s3:GetObject"
                        - "s3:PutObject"
                      "Effect": "Allow"
                      "Resource": "*"
            Roles:
                - !Ref RoleForECS

    PolicyForStepFunctions:
        Type: AWS::IAM::Policy
        Properties:
            PolicyName: PolicyForStepFunctions-Lambda-StepFunctions-Sample
            PolicyDocument:
                Version: 2012-10-17
                Statement:
                    - "Action":
                        - "lambda:InvokeFunction"
                        - "events:*"
                        - "logs:*"
                        - "iam:*"
                        - "ec2:*"
                        - "ecs:*"
                        - "ecr:*"
                        - "elasticloadbalancing:*"
                        - "route53:*"
                        - "servicediscovery:*"
                        - "sqs:*"
                      "Effect": "Allow"
                      "Resource": "*"
            Roles:
                - !Ref RoleForStepFunctions

    PolicyForCloudWatchEvent:
        Type: AWS::IAM::Policy
        Properties:
            PolicyName: PolicyForCloudWatchEvent-Lambda-StepFunctions-Sample
            PolicyDocument:
                Version: 2012-10-17
                Statement:
                    - "Action":
                        - "states:StartExecution"
                        - "logs:*"
                      "Effect": "Allow"
                      "Resource": "*"
            Roles:
                - !Ref RoleForCloudWatchEvent

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
            DefinitionString:
                Fn::Sub: |-
                    {% filter indent(20, False) %}
                    {%- include "20190522_Functions_chaining/statemachine.json" -%}
                    {%- endfilter %}
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

    StateMachineActivityExecuteTask:
        Type: AWS::StepFunctions::StateMachine
        Properties:
            StateMachineName: Sample_StateMachine_Activity_Execute_Task
            DefinitionString:
                Fn::Sub: |-
                    {% filter indent(20, False) %}
                    {%- include "20191003_Activity_execute_task/statemachine.json" -%}
                    {%- endfilter %}
            RoleArn: !GetAtt RoleForStepFunctions.Arn

    # **************************************************
    # ----- VPC
    # **************************************************
    # VPC and Subnet
    Vpc:
        Type: AWS::EC2::VPC
        Properties:
            CidrBlock: 10.0.0.0/16

    SubnetPubA:
        Type: AWS::EC2::Subnet
        Properties:
            AvailabilityZone: ap-northeast-1a
            CidrBlock: 10.0.1.0/24
            VpcId: !Ref Vpc

    SubnetPubC:
        Type: AWS::EC2::Subnet
        Properties:
            AvailabilityZone: ap-northeast-1c
            CidrBlock: 10.0.2.0/24
            VpcId: !Ref Vpc

    SubnetPriA:
        Type: AWS::EC2::Subnet
        Properties:
            AvailabilityZone: ap-northeast-1a
            CidrBlock: 10.0.3.0/24
            VpcId: !Ref Vpc

    SubnetPriC:
        Type: AWS::EC2::Subnet
        Properties:
            AvailabilityZone: ap-northeast-1c
            CidrBlock: 10.0.4.0/24
            VpcId: !Ref Vpc

    # Internet Gateway
    InternetGateway:
        Type: AWS::EC2::InternetGateway

    InternetGatewayAttachment:
        Type: AWS::EC2::VPCGatewayAttachment
        Properties:
            InternetGatewayId: !Ref InternetGateway
            VpcId: !Ref Vpc

    # Elastic IP
    ElasticIPAzA:
        Type: AWS::EC2::EIP
        Properties:
            Domain: vpc

    ElasticIPAzC:
        Type: AWS::EC2::EIP
        Properties:
            Domain: vpc

    # NAT Gateway
    NATGatewayAzA:
        Type: AWS::EC2::NatGateway
        Properties:
            AllocationId: !GetAtt ElasticIPAzA.AllocationId
            SubnetId: !Ref SubnetPubA

    NATGatewayAzC:
        Type: AWS::EC2::NatGateway
        Properties:
            AllocationId: !GetAtt ElasticIPAzC.AllocationId
            SubnetId: !Ref SubnetPubC

    # Route table for public subnet
    # Public subnet A / C => Internet Gateway
    RouteTablePublic:
        Type: AWS::EC2::RouteTable
        Properties:
            VpcId: !Ref Vpc

    RouteDefaultPublic:
        Type: AWS::EC2::Route
        Properties:
            DestinationCidrBlock: 0.0.0.0/0
            GatewayId: !Ref InternetGateway
            RouteTableId: !Ref RouteTablePublic

    RouteDefaultPublicAssociationAzA:
        Type: AWS::EC2::SubnetRouteTableAssociation
        Properties:
            RouteTableId: !Ref RouteTablePublic
            SubnetId: !Ref SubnetPubA

    RouteDefaultPublicAssociationAzC:
        Type: AWS::EC2::SubnetRouteTableAssociation
        Properties:
            RouteTableId: !Ref RouteTablePublic
            SubnetId: !Ref SubnetPubC

    # Route table for private subnet A
    # Private subnet A => NAT Gateway in Public subnet A
    RouteTablePrivateAzA:
        Type: AWS::EC2::RouteTable
        Properties:
            VpcId: !Ref Vpc

    RouteDefaultPrivateAzA:
        Type: AWS::EC2::Route
        Properties:
            DestinationCidrBlock: 0.0.0.0/0
            NatGatewayId: !Ref NATGatewayAzA
            RouteTableId: !Ref RouteTablePrivateAzA

    RouteDefaultPrivateAssociationAzA:
        Type: AWS::EC2::SubnetRouteTableAssociation
        Properties:
            RouteTableId: !Ref RouteTablePrivateAzA
            SubnetId: !Ref SubnetPriA

    # Route table for private subnet C
    # Private subnet C => NAT Gateway in Public subnet C
    RouteTablePrivateAzC:
        Type: AWS::EC2::RouteTable
        Properties:
            VpcId: !Ref Vpc

    RouteDefaultPrivateAzC:
        Type: AWS::EC2::Route
        Properties:
            DestinationCidrBlock: 0.0.0.0/0
            NatGatewayId: !Ref NATGatewayAzC
            RouteTableId: !Ref RouteTablePrivateAzC

    RouteDefaultPrivateAssociationAzC:
        Type: AWS::EC2::SubnetRouteTableAssociation
        Properties:
            RouteTableId: !Ref RouteTablePrivateAzC
            SubnetId: !Ref SubnetPriC

    # Security Group
    SecurityGroup:
        Type: AWS::EC2::SecurityGroup
        Properties:
            GroupName: security-group-lambda-stepfunctions-sample
            GroupDescription: Security group for Samples-AWS-Serverless-Application
            SecurityGroupEgress:
                -
                    IpProtocol: tcp
                    FromPort: 3306
                    ToPort: 3306
                    CidrIp: 0.0.0.0/0
            SecurityGroupIngress:
                -
                    IpProtocol: tcp
                    FromPort: 3306
                    ToPort: 3306
                    CidrIp: 0.0.0.0/0
            VpcId: !Ref Vpc

# End
