"""
Name: create_random_values
Description: 
Created by: Masato Shima
Created on: 2019/09/01
"""

# **************************************************
# ----- Import Library
# **************************************************
import logging
import traceback
import datetime
import random
from typing import *


# **************************************************
# ----- Variables
# **************************************************
STATUS_SUCCESS = "SUCCESS"
STATUS_FAILED = "FAILED"

current_time = None


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
def lambda_handler(event: Dict, context: Dict) -> Dict:
	global current_time

	current_time = datetime.datetime.today()

	logger.info("Start -- lambda_handler")

	status = STATUS_FAILED

	values = None

	try:
		values = create_random_values()

		status = STATUS_SUCCESS

	except Exception as error_info:
		status = STATUS_FAILED

		logger.error(
			f"Failed... "
			f"\n{error_info}"
			f"\n{traceback.format_exc()}"
		)

	finally:
		logger.info("End -- lambda_handler")

		return {
			"status": status,
			"data": values
		}


# **************************************************
# ----- End
# **************************************************
def create_random_values() -> List[int, ]:
	values = random.sample(range(1, 100), 10)

	return values


# **************************************************
# ----- End
# **************************************************
