"""
Name: Lambda_StepFunctions_Sample_Get
Description: S3からファイルを取得し、その内容を戻り値として返す
Created by: Masato Shima
Created on: 2019/05/22
"""

# **************************************************
# ----- Import Library
# **************************************************
import logging
import traceback
import simplejson
import boto3


# **************************************************
# ----- Variables
# **************************************************
STATUS_SUCCESS = "SUCCESS"
STATUS_FAILED = "FAILED"


# **************************************************
# ----- Connect AWS resources
# **************************************************
s3 = boto3.client("s3")


# **************************************************
# ----- Set logger
# **************************************************
logger = logging.getLogger()
logger.setLevel(logging.INFO)


# **************************************************
# ----- lambda_handler
# **************************************************
def lambda_handler(event: dict, context: dict) -> dict:
	logger.info(f"Start -- lambda_handler")

	status = STATUS_FAILED

	data = None

	try:
		logging.info(simplejson.dumps(event, ensure_ascii=False, encoding="utf-8", indent=4))

		data = _get_file_from_s3(event)

		status = STATUS_SUCCESS

	except Exception as error_info:
		logger.error(
			f"Failed... "
			f"\n{error_info}"
			f"\n{traceback.format_exc()}"
		)

	finally:
		logger.info(f"End -- lambda_handler")

		return {
			"status": status,
			"data": data
		}


# **************************************************
# ----- Function get_file_from_s3
# **************************************************
def _get_file_from_s3(event: dict) -> dict:
	arn = event["detail"]["resources"][0]["ARN"]
	bucket = arn.split(":::")[1].split("/")[0]
	key = arn.split(":::")[1].split("/")[1]

	response = s3.get_object(
		Bucket=bucket,
		Key=key
	)

	data = response["Body"].read().decode("utf-8", errors="replace")
	data = simplejson.loads(data)

	return data


# **************************************************
# ----- End
# **************************************************
