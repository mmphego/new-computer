#!/usr/bin/env python

import argparse
import json
import requests
import sys

api_url = 'https://api.github.com/user/gpg_keys'

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--username', required=True, help="GitHub Username")
    parser.add_argument('-p', '--password', required=True, help="GitHub Password")
    parser.add_argument('-f', '--key_file', required=True, help="File containing PGP Pub Key")
    args = vars(parser.parse_args())
    session = requests.Session()
    session.auth = (args.get('username'), args.get('password'))

    with open(args.get('key_file')) as f:
        gpg_key = f.readlines()

    json_data_dump = json.dumps({'armored_public_key': ''.join(gpg_key)})
    resp = session.post(api_url, data=json_data_dump)
    sys.exit(0) if resp.status_code == 201 else sys.exit(1)

if __name__ == "__main__":
    main()
