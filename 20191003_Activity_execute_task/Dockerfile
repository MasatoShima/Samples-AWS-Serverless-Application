# """
# Name: Dockerfile
# Description: Sample Application
# Created by: Masato Shima
# Created on: 2019/10/03
# """

FROM python:3

WORKDIR /usr/src/app

COPY app.py ./
COPY run.sh ./

RUN pip install boto3

# 以下のコマンドは AWS ECS 側で上書きされることを期待する
CMD ["/usr/src/app/run.sh", "$1"]

# End
