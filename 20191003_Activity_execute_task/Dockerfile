# """
# Name: Dockerfile
# Description: Sample Application
# Created by: Masato Shima
# Created on: 2019/10/03
# """

FROM python:3

WORKDIR /usr/src/app

# 必要なファイルを COPY
COPY app.py ./

# 実行権限を付与
RUN chmod 775 ./app.py

# 必要なライブラリをインストール
RUN pip install boto3

# CMD は Fargate 側が Task 実行時に上書きする
ENTRYPOINT ["python", "app.py", "-a"]
CMD []

# End
