from subprocess import check_call
import sys

BUILD_NAME = sys.argv[1]

def call(cmd):
    check_call(cmd, shell=True)

if BUILD_NAME == "ACCEPTANCE":
    call('python run.py')
else:
    raise ValueError(BUILD_NAME)
