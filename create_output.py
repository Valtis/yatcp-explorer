#!/bin/python3

import json


json_data = {}

with open("compile_stderr", "r") as f:
    content = f.read()
    json_data["compile_stderr"] = content

with open("gcc_stderr", "r") as f:
    content = f.read()
    json_data["gcc_stderr"] = content

with open("program_stderr", "r") as f:
    content = f.read()
    json_data["program_stderr"] = content


with open("program_stdout", "r") as f:
    content = f.read()
    json_data["program_stdout"] = content

with open("asm", "r") as f:
    content = f.read()
    json_data["asm"] = content

with open("output", "w") as output:
    json.dump(json_data, output)    

