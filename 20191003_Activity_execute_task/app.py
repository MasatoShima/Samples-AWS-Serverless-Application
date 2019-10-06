"""
Name: app.py
Description: 
Created by: Masato Shima
Created on: 2019/10/03
"""

# **************************************************
# ----- Import Library
# **************************************************
import os
import sys
import argparse
import traceback
import json
import boto3
from typing import *
from logging import *


# **************************************************
# ----- Variables
# **************************************************


# **************************************************
# ----- Data Model
# **************************************************


# **************************************************
# ----- Arg parse
# **************************************************
# parser 作成
parser = argparse.ArgumentParser(
	prog="app.py",
	usage="Run Script with appropriate arguments (-h, --help) .",
	description="Get object from S3 and return it",
	epilog="End",
	add_help=True
)

# パラメータ作成
parser.add_argument(
	"-e",
	"--event",
	action="store",
	required=False,
	help="event object from S3"
)

args = parser.parse_args()


# **************************************************
# ----- Set logger
# **************************************************
logger = getLogger(__name__)
logger.setLevel(INFO)

handler = StreamHandler()
handler.setLevel(INFO)
handler.setFormatter(Formatter("%(asctime)s\t%(levelname)s\t%(message)s"))

logger.addHandler(handler)
logger.propagate = False


# **************************************************
# ----- Connect AWS resources
# **************************************************
s3 = boto3.client("s3")


# **************************************************
# ----- Main
# **************************************************
def main(event):
	data = _get_object(event)

	return {
		"status": "SUCCESS",
		"data": data
	}


# **************************************************
# ----- Function get_object
# **************************************************
def _get_object(event: Dict[str, Any]) -> str:
	arn = event["detail"]["resources"][0]["ARN"]
	bucket = arn.split(":::")[1].split("/")[0]
	key = arn.split(":::")[1].split("/")[1]

	response = s3.get_object(
		Bucket=bucket,
		Key=key
	)

	data = response["Body"].read().decode("utf-8", errors="replace")
	data = json.loads(data)

	return data


# **************************************************
# ----- Main Process
# **************************************************
if __name__ == '__main__':
	os.chdir(os.path.dirname(os.path.abspath(__file__)))

	try:
		logger.info("Start main process")

		main(args.event)

		status = 0

		logger.info("End main process")

	except Exception as error_info:
		logger.error("Failed main process")
		logger.error(error_info)
		logger.error(traceback.format_exc())

		status = 1

	sys.exit(status)


# **************************************************
# ----- End
# **************************************************
