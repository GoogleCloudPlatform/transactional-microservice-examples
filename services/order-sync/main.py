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
import uuid

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
    return 'Order service / Synchronous implementation. '


@app.route('/api/v1/order/create', methods=['POST'])
@app.route('/order-service-sync/api/v1/order/create', methods=['POST'])
def order_create():
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

    order = {
        'customer_id': customer_id,
        'order_id': str(uuid.uuid4()),
        'number': number,
        'status': 'pending'
    }
    incomplete_key = ds_client.key('Order')
    order_entity = datastore.Entity(key=incomplete_key)
    order_entity.update(order)
    ds_client.put(order_entity)

    return order, 200


@app.route('/api/v1/order/get', methods=['POST'])
@app.route('/order-service-sync/api/v1/order/get', methods=['POST'])
def order_get():
    json_data = request.get_json()
    customer_id, order_id = None, None
    invalid_fields = []
    for key in json_data.keys():
        if key == 'customer_id':
            customer_id = json_data[key]
        elif key == 'order_id':
            order_id = json_data[key]
        else:
            invalid_fields.append(key)
    if customer_id is None or order_id is None:
        return error500()

    query = ds_client.query(kind='Order')
    query.add_filter('customer_id', '=', customer_id)
    query.add_filter('order_id', '=', order_id)
    resp = None
    for result in query.fetch(): # This should return a single entity.
        resp = {
            'customer_id': result['customer_id'],
            'order_id': result['order_id'],
            'number': result['number'],
            'status': result['status']
        }
        break
    if resp is None:
        return error500()

    return resp, 200


@app.route('/api/v1/order/update', methods=['POST'])
@app.route('/order-service-sync/api/v1/order/update', methods=['POST'])
def order_update():
    json_data = request.get_json()
    customer_id, order_id, status = None, None, None
    invalid_fields = []
    for key in json_data.keys():
        if key == 'customer_id':
            customer_id = json_data[key]
        elif key == 'order_id':
            order_id = json_data[key]
        elif key == 'status':
            status = json_data[key]
        else:
            invalid_fields.append(key)
    if customer_id is None or order_id is None or status is None:
        return error500()

    query = ds_client.query(kind='Order')
    query.add_filter('customer_id', '=', customer_id)
    query.add_filter('order_id', '=', order_id)
    resp = None
    for result in query.fetch(): # This should return a single entity.
        resp = {
            'customer_id': result['customer_id'],
            'order_id': result['order_id'],
            'number': result['number'],
            'status': status
        }
        result.update(resp)
        ds_client.put(result)
        break
    if resp is None:
        return error500()

    return resp, 200


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
