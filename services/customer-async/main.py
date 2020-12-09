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
    return 'Customer service / Asynchronous implementation. '


@app.route('/api/v1/customer/get', methods=['POST'])
@app.route('/customer-service-async/api/v1/customer/get', methods=['POST'])
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
@app.route('/customer-service-async/api/v1/customer/limit', methods=['POST'])
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


# Event handler
@app.route('/api/v1/customer/pubsub', methods=['POST'])
def customer_pubsub():
    envelope = request.get_json()
    if not isinstance(envelope, dict) or 'message' not in envelope:
        return error500()
    message = envelope['message']
    if 'data' not in message or 'attributes' not in message:
        return error500()
    attributes = message['attributes']
    if 'event_id' not in attributes or 'event_type' not in attributes:
        return error500()

    order = json.loads(base64.b64decode(message['data']).decode('utf-8'))
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

    customer_id = order['customer_id']
    number = order['number']

    query = ds_client.query(kind='Customer')
    query.add_filter('customer_id', '=', customer_id)
    customer = None
    for result in query.fetch(): # This should return a single entity.
        customer = result
        break
    if not customer: # Non existing customer_id
        return error500()

    accept = None
    credit = customer['credit']
    limit = customer['limit']
    credit += number * 100

    with ds_client.transaction():
        if credit > limit: # Reject order
            accept = False
        else: # Accept order
            accept = True
            customer['credit'] = credit
            ds_client.put(customer)

        check_result = {
            'customer_id': customer_id,
            'order_id': order['order_id'],
            'accepted': accept
        }
        event = {
            'event_id': str(uuid.uuid4()),
            'topic': 'customer-service-event',
            'type': 'order_checked',
            'timestamp': datetime.datetime.utcnow(),
            'published': False,
            'body': json.dumps(check_result)
        }

        incomplete_key = ds_client.key('Event')
        event_entity = datastore.Entity(key=incomplete_key)
        event_entity.update(event)
        ds_client.put(event_entity)

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
