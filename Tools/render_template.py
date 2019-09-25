"""
Name: render_template
Description: 
Created by: Masato Shima
Created on: 2019/09/25
"""

# **************************************************
# ----- Import Library
# **************************************************
import os
import argparse
import jinja2
from jinja2 import Environment, FileSystemLoader
from typing import *


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
	prog="render_template.py",
	usage="Run Script with appropriate arguments (-h, --help) .",
	description="Render template file.",
	epilog="End",
	add_help=True
)

# パラメータ作成（ レンダリングするテンプレートファイルの元データとなるファイルの Path ）
parser.add_argument(
	"-t",
	"--template",
	action="store",
	required=False,
	help=(
		"The path of the file "
		"that is the original data of the template file to be rendered"
	)
)

args = parser.parse_args()


# **************************************************
# ----- Main
# **************************************************
def main():
	template = load_template()

	template_rendered = render_template(template)

	output_rendered_template(template_rendered)

	return


# **************************************************
# ----- Function load_template
# **************************************************
def load_template() -> jinja2.Template:
	file_path, file_name = os.path.split(args.template)

	template = Environment(
		loader=FileSystemLoader(f"{file_path}/", encoding="utf-8")
	)

	template = template.get_template(file_name)

	return template


# **************************************************
# ----- Function render_template
# **************************************************
def render_template(template: jinja2.Template) -> str:
	template_rendered = template.render()

	return template_rendered


# **************************************************
# ----- Function output_rendered_template
# **************************************************
def output_rendered_template(template_rendered: str) -> None:
	file_path, _ = os.path.split(args.template)

	with open(f"{file_path}/template.yaml", "w", encoding="utf-8") as file:
		file.write(template_rendered)

	return


# **************************************************
# ----- Main Process
# **************************************************
if __name__ == '__main__':
	main()


# **************************************************
# ----- End
# **************************************************
