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


import base64
import copy
import datetime
import json
import os
import urllib

import google.auth.transport.requests
import google.oauth2.id_token
from google.cloud import datastore, bigquery

from flask import Flask, request


PRODUCT_SERVICE_URL = os.getenv('PRODUCT_SERVICE_URL')


app = Flask(__name__)
ds_client = datastore.Client()
bq_client = bigquery.Client()


def error500():
    resp = {
        'message': 'Internal error occured.'
    }
    return resp, 500


@app.route('/')
def index():
    return 'Order information service for CQRS pattern. '


@app.route('/api/v1/orderinfo/list', methods=['POST'])
@app.route('/orderinfo-service-cqrs/api/v1/orderinfo/list', methods=['POST'])
def order_list():
    json_data = request.get_json()
    customer_id, order_date = None, None
    for key in json_data.keys():
        if key == 'customer_id':
            customer_id = json_data[key]
        elif key == 'order_date':
            order_date = json_data[key]
        else:
            invalid_fields.append(key)
    if customer_id is None or order_date is None:
        return error500()

    query = ds_client.query(kind='OrderInformationCQRS')
    query.add_filter('customer_id', '=', customer_id)
    query.add_filter('order_date', '>=', order_date)
    query.add_filter('order_date', '<', order_date + u'\ufffd')
    orders = []
    for result in query.fetch():
        orders.append({
            'order_id': result['order_id'],
            'customer_id': result['customer_id'],
            'product_id': result['product_id'],
            'product_name': result['product_name'],
            'number': result['number'],
            'unit_price': result['unit_price'],
            'total_price': result['total_price'],
            'order_date': result['order_date'],
        })
    resp = {"order_date": order_date, "orders": orders}

    return resp, 200


@app.route('/api/v1/orderinfo/get', methods=['POST'])
@app.route('/orderinfo-service-cqrs/api/v1/orderinfo/get', methods=['POST'])
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

    query = ds_client.query(kind='OrderInformationCQRS')
    query.add_filter('customer_id', '=', customer_id)
    query.add_filter('order_id', '=', order_id)
    resp = None
    for result in query.fetch(): # This should return a single entity.
        resp = {
            'order_id': result['order_id'],
            'customer_id': result['customer_id'],
            'product_id': result['product_id'],
            'product_name': result['product_name'],
            'number': result['number'],
            'unit_price': result['unit_price'],
            'total_price': result['total_price'],
            'order_date': result['order_date'],
        }
        break
    if resp is None:
        resp = {'message': 'The order does not exist.'}

    return resp, 200


# Event handler
@app.route('/api/v1/orderinfo/pubsub', methods=['POST'])
def order_pubsub():
    envelope = request.get_json()
    if not isinstance(envelope, dict) or 'message' not in envelope:
        return error500()
    message = envelope['message']
    if 'data' not in message or 'attributes' not in message:
        return error500()
    attributes = message['attributes']
    if 'event_id' not in attributes or 'event_type' not in attributes:
        return error500()

    order_event = json.loads(base64.b64decode(message['data']).decode('utf-8'))
    event_id = attributes['event_id']
    event_type = attributes['event_type']

    query = ds_client.query(kind='ProcessedEvent')
    query.keys_only()
    query.add_filter('event_id', '=', event_id)
    if list(query.fetch()): # duplicate
        print('Duplicate event {}'.format(event_id))
        return 'Finished.', 200

    if event_type != 'order_create':
        print('Unknown event type {}.format(event_type)')
        return 'Finished.', 200

    customer_id = order_event['customer_id']
    order_id = order_event['order_id']
    customer_id = order_event['customer_id']
    product_id = order_event['product_id']
    number = order_event['number']
    order_date = order_event['order_date']

    # get product_name and unit_price from product service.
    url = PRODUCT_SERVICE_URL + '/api/v1/product/get'
    credentials, _ = google.auth.default()
    auth_req = google.auth.transport.requests.Request()
    id_token = google.oauth2.id_token.fetch_id_token(auth_req, url)
    data = {'product_id': product_id}
    headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer {}'.format(id_token)
    }
    req = urllib.request.Request(url, json.dumps(data).encode(), headers)
    result = None
    try:
        with urllib.request.urlopen(req) as res:
            result = json.load(res)
    except urllib.error.HTTPError as err:
        return 'Finished.', 200

    product_name = result['product_name']
    unit_price = result['unit_price']
    
    order_info = {
        'customer_id': customer_id,
        'order_id': order_id,
        'product_id': product_id,
        'number': number,
        'product_name': product_name,
        'unit_price': unit_price,
        'total_price': unit_price * number,
        'order_date': order_date
    }

    # Insert into bq table
    table_ref = bq_client.dataset('cqrs_example').table('order_information')
    table = bq_client.get_table(table_ref)
    order_info_bq = copy.deepcopy(order_info)
    order_info_bq['order_date'] = datetime.datetime.strptime(
        order_info_bq['order_date'], '%Y-%m-%d').date()
    rows = [order_info_bq]
    bq_client.insert_rows(table, rows)
    
    with ds_client.transaction():
        incomplete_key = ds_client.key('OrderInformationCQRS')
        order_info_entity = datastore.Entity(key=incomplete_key)
        order_info_entity.update(order_info)
        ds_client.put(order_info_entity)

        incomplete_key = ds_client.key('ProcessedEvent')
        entity = datastore.Entity(key=incomplete_key)
        entity.update({
            'event_id': event_id,
            'timestamp': datetime.datetime.utcnow()
        })
        ds_client.put(entity)

    return 'Finished.', 200


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
