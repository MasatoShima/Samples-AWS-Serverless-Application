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
COPY run.sh ./

# 実行権限を付与
RUN sudo chmod 775 ./app.py
RUN sudo chmod 775 ./run.sh

# 必要なライブラリをインストール
RUN pip install boto3

# 以下のコマンドは AWS ECS 側で上書きされることを期待する
CMD ["/usr/src/app/run.sh", "$1"]

# End
