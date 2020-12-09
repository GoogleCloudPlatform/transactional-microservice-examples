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

import os

from google.cloud import datastore

from flask import Flask, request

app = Flask(__name__)
ds_client = datastore.Client()


def error500():
    resp = {
        'message': 'Internal error occured.'
    }
    return resp, 500


@app.route('/')
def index():
    return 'Customer service / Synchronous implementation. '


@app.route('/api/v1/customer/get', methods=['POST'])
@app.route('/customer-service-sync/api/v1/customer/get', methods=['POST'])
def customer_get():
    json_data = request.get_json()
    customer_id = None
    invalid_fields = []
    for key in json_data.keys():
        if key == 'customer_id':
            customer_id = json_data[key]
        else:
            invalid_fields.append(key)
    if customer_id is None:
        return error500()

    query = ds_client.query(kind='Customer')
    query.add_filter('customer_id', '=', customer_id)
    resp = None
    for result in query.fetch(): # This should return a single entity.
        resp = {
            'customer_id': result['customer_id'],
            'credit': result['credit'],
            'limit': result['limit']
        }
        break
    if resp is None:
        return error500()

    return resp, 200


@app.route('/api/v1/customer/limit', methods=['POST'])
@app.route('/customer-service-sync/api/v1/customer/limit', methods=['POST'])
def customer_limit():
    json_data = request.get_json()
    customer_id, limit = None, None
    invalid_fields = []
    for key in json_data.keys():
        if key == 'customer_id':
            customer_id = json_data[key]
        elif key == 'limit':
            limit = json_data[key]
        else:
            invalid_fields.append(key)
    if customer_id is None or limit is None:
        return error500()

    query = ds_client.query(kind='Customer')
    query.add_filter('customer_id', '=', customer_id)
    resp = None
    for result in query.fetch(): # This should return a single entity.
        credit = result['credit']
        if limit < credit:
            return error500()
        resp = {
            'customer_id': customer_id,
            'credit': credit,
            'limit': limit
        }
        result.update(resp)
        ds_client.put(result)
        break

    if resp is None: # Create a new customer entry.
        resp = {
            'customer_id': customer_id,
            'credit': 0,
            'limit': limit
        }
        incomplete_key = ds_client.key('Customer')
        customer_entity = datastore.Entity(key=incomplete_key)
        customer_entity.update(resp)
        ds_client.put(customer_entity)

    return resp, 200


# Event hander
@app.route('/api/v1/customer/reserve', methods=['POST'])
@app.route('/customer-service-sync/api/v1/customer/reserve', methods=['POST'])
def customer_reserve():
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

    query = ds_client.query(kind='Customer')
    query.add_filter('customer_id', '=', customer_id)
    resp = None
    for result in query.fetch(): # This should return a single entity.
        credit = result['credit']
        limit = result['limit']
        if credit + number * 100 > limit: # Reject
            accept = False
        else: # Accept
            accept = True
            result['credit'] = credit + number * 100
            ds_client.put(result)
        resp = {
            'customer_id': customer_id,
            'credit': result['credit'],
            'accepted': accept
        }
        break

    if resp is None:
        return error500()

    return resp, 200


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
