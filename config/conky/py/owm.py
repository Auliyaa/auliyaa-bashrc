#!/usr/bin/env python3

import argparse
import requests
import json
import subprocess
import sys

parser = argparse.ArgumentParser(description='Conky data fetcher.')
parser.add_argument('--key',help='OWM API key.')
parser.add_argument('--query',help='OWM query string.')
args = parser.parse_args()

url = "http://api.openweathermap.org/data/2.5/weather?q=%s,FR&appid=%s&units=metric" % (args.query,args.key)

try:
    response = requests.get(url)
except:
    sys.exit()
if response.status_code != 200:
    sys.exit()

j=response.json()

print(json.dumps(j))
