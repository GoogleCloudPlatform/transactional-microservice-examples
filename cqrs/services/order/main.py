# Copyright 2021 Google Inc.
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


import datetime
import json
import os
import re
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
    return 'Order service for CQRS pattern. '


@app.route('/api/v1/order/create', methods=['POST'])
@app.route('/order-service-cqrs/api/v1/order/create', methods=['POST'])
def order_create():
    json_data = request.get_json()
    customer_id, product_id, number, order_date = None, None, None, None
    invalid_fields = []
    for key in json_data.keys():
        if key == 'customer_id':
            customer_id = json_data[key]
        elif key == 'product_id':
            product_id = json_data[key]
        elif key == 'number':
            number = json_data[key]
        elif key == 'order_date':
            order_date = json_data[key]
        else:
            invalid_fields.append(key)
    if order_date is None:
        order_date = datetime.date.today().strftime('%Y-%m-%d')
    else:
        result = re.match(r'^(\d{4}-\d{2}-\d{2})$', order_date)
        if result:
            order_date = result.group(1) # '%Y-%m-%d'
            #order_date = datetime.datetime.strptime(result.group(1), '%Y-%m-%d')
        else:
            order_date = None

    if customer_id is None or number is None or product_id is None:
        return error500()

    order = {
        'customer_id': customer_id,
        'order_id': str(uuid.uuid4()),
        'product_id': product_id,
        'number': number,
        'order_date': order_date
    }
    event = {
        'event_id': str(uuid.uuid4()),
        'topic': 'order-service-cqrs-event',
        'type': 'order_create',
        'timestamp': datetime.datetime.utcnow(),
        'published': False,
        'body': json.dumps(order)
    }

    with ds_client.transaction():
        incomplete_key = ds_client.key('OrderCQRS')
        order_entity = datastore.Entity(key=incomplete_key)
        order_entity.update(order)
        ds_client.put(order_entity)

        incomplete_key = ds_client.key('Event')
        event_entity = datastore.Entity(key=incomplete_key)
        event_entity.update(event)
        ds_client.put(event_entity)

    return order, 200


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
