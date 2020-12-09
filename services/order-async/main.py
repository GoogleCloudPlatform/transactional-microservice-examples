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
import datetime
import json
import os
import uuid

from flask import Flask, request

from google.cloud import datastore


app = Flask(__name__)
ds_client = datastore.Client()


def error500():
    resp = {
        'message': 'Internal error occured.'
    }
    return resp, 500


@app.route('/')
def index():
    return 'Order service / Asynchronous implementation. '


@app.route('/api/v1/order/create', methods=['POST'])
@app.route('/order-service-async/api/v1/order/create', methods=['POST'])
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
    event = {
        'event_id': str(uuid.uuid4()),
        'topic': 'order-service-event',
        'type': 'order_create',
        'timestamp': datetime.datetime.utcnow(),
        'published': False,
        'body': json.dumps(order)
    }

    with ds_client.transaction():
        incomplete_key = ds_client.key('Order')
        order_entity = datastore.Entity(key=incomplete_key)
        order_entity.update(order)
        ds_client.put(order_entity)

        incomplete_key = ds_client.key('Event')
        event_entity = datastore.Entity(key=incomplete_key)
        event_entity.update(event)
        ds_client.put(event_entity)

    return order, 200


@app.route('/api/v1/order/get', methods=['POST'])
@app.route('/order-service-async/api/v1/order/get', methods=['POST'])
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


# Event handler
@app.route('/api/v1/order/pubsub', methods=['POST'])
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

    check_result = json.loads(base64.b64decode(message['data']).decode('utf-8'))
    event_id = attributes['event_id']
    event_type = attributes['event_type']

    query = ds_client.query(kind='ProcessedEvent')
    query.keys_only()
    query.add_filter('event_id', '=', event_id)
    if list(query.fetch()): # duplicate
        print('Duplicate event {}'.format(event_id))
        return 'Finished.', 200

    if event_type != 'order_checked':
        print('Unknown event type {}.format(event_type)')
        return 'Finished.', 200

    customer_id = check_result['customer_id']
    order_id = check_result['order_id']
    accepted = check_result['accepted']

    query = ds_client.query(kind='Order')
    query.add_filter('customer_id', '=', customer_id)
    query.add_filter('order_id', '=', order_id)
    order = None
    for result in query.fetch(): # This should return a single entity.
        order = result
        break
    if order is None: # Non existing order
        return error500()

    with ds_client.transaction():
        if accepted:
            order['status'] = 'accepted'
        else:
            order['status'] = 'rejected'
        ds_client.put(order)

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
