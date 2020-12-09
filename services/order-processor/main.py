# Copyright 2020 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import json
import os
import time

import requests

from flask import Flask, request

app = Flask(__name__)

PROJECT_ID = os.getenv('PROJECT_ID')
REGION = os.getenv('REGION') or 'us-central1'
WORKFLOW = os.getenv('WORKFLOW') or 'order_workflow'

def error500():
    resp = {
        'message': 'Internal error occured.'
    }
    return resp, 500


def get_access_token(scopes='https://www.googleapis.com/auth/cloud-platform'):
    url = 'http://metadata.google.internal/computeMetadata' \
          '/v1/instance/service-accounts/default/token?scopes={}'.format(scopes)
    resp = requests.get(url, headers={"Metadata-Flavor": "Google"})
    resp = json.loads(resp.text)
    return resp['access_token']


@app.route('/')
def index():
    return 'Order process executor service. '


@app.route('/api/v1/order/process', methods=['POST'])
@app.route('/order-processor-service/api/v1/order/process', methods=['POST'])
def order_process():
    json_data = request.get_json()
    customer_id, number = None, None
    invalid_fields = []
    for key in json_data.keys():
        if key == 'customer_id':
            customer_id = json_data[key]
        elif key == 'number':
            number = json_data[key]
        else:
            invalid_fields.append(key)
    if customer_id is None or number is None:
        return error500()

    token = get_access_token()

    # Execute workflow
    service_url = 'https://workflowexecutions.googleapis.com/v1beta' \
                  '/projects/{}/locations/{}/workflows/{}/executions'.format(
                      PROJECT_ID, REGION, WORKFLOW)
    headers = {"Authorization": "Bearer {}".format(token),
               "Content-Type": "application/json"}
    data = {"argument": '{{"customer_id":"{}", "number":{}}}'.format(customer_id, number)}
    resp = requests.post(service_url, headers=headers, json=data)
    resp = json.loads(resp.text)
    job_name = resp['name']

    # Wait for the excecution to finish
    service_url = 'https://workflowexecutions.googleapis.com/v1beta/{}'.format(job_name)
    headers = {"Authorization": "Bearer {}".format(token)}
    while True:
        resp = requests.get(service_url, headers=headers)
        resp = json.loads(resp.text)
        state = resp['state']
        if state == 'SUCCEEDED':
            result = json.loads(resp['result'])
            return result, 200
        if state == 'FAILED':
            return error500()
        time.sleep(5)


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
