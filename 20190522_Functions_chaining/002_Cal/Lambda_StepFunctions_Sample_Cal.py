"""
Name: Lambda_StepFunctions_Sample_Cal
Description: イベントオブジェクトを参照し、所定の位置に格納されている数値データを2乗する
Created by: Masato Shima
Created on: 2019/05/22
"""


# **************************************************
# ----- Import Library
# **************************************************
import logging
import traceback
import simplejson


# **************************************************
# ----- Variables
# **************************************************
STATUS_SUCCESS = "SUCCESS"
STATUS_FAILED = "FAILED"


# **************************************************
# ----- Connect AWS resources
# **************************************************


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

	value = None

	try:
		logging.info(simplejson.dumps(event, ensure_ascii=False, encoding="utf-8", indent=4))

		value = _cal_square(event)

		status = STATUS_SUCCESS

	except Exception as error_info:
		logger.error(
			f"[Failed... "
			f"\n{error_info}"
			f"\n{traceback.format_exc()}"
		)

	finally:
		logger.info(f"End -- lambda_handler")

		return {
			"status": status,
			"value": value
		}


# **************************************************
# ----- cal_square
# **************************************************
def _cal_square(event: dict) -> int:
	value = event["data"]["value"] ** 2

	return value


# **************************************************
# ----- End
# **************************************************
