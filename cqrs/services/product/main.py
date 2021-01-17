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
    return 'Product service for CQRS pattern. '


@app.route('/api/v1/product/create', methods=['POST'])
@app.route('/product-service-cqrs/api/v1/product/create', methods=['POST'])
def product_create():
    json_data = request.get_json()
    product_id, product_name, unit_price = None, None, None
    invalid_fields = []
    for key in json_data.keys():
        if key == 'product_id':
            product_id = json_data[key]
        elif key == 'product_name':
            product_name = json_data[key]
        elif key == 'unit_price':
            unit_price = json_data[key]
        else:
            invalid_fields.append(key)
    if product_id is None or product_name is None or unit_price is None:
        return error500()

    product = {
        'product_id': product_id,
        'product_name': product_name,
        'unit_price': unit_price
    }

    # Check the existing prodcut_id
    query = ds_client.query(kind='ProductCQRS')
    query.add_filter('product_id', '=', product_id)
    exist = False
    for result in query.fetch(): # This should return a single entity.
        result.update(product)
        ds_client.put(result)
        exist = True
        break
    if not exist:
        incomplete_key = ds_client.key('ProductCQRS')
        product_entity = datastore.Entity(key=incomplete_key)
        product_entity.update(product)
        ds_client.put(product_entity)

    return product, 200


@app.route('/api/v1/product/get', methods=['POST'])
@app.route('/product-service-cqrs/api/v1/product/get', methods=['POST'])
def product_get():
    json_data = request.get_json()
    product_id = None
    invalid_fields = []
    for key in json_data.keys():
        if key == 'product_id':
            product_id = json_data[key]
        else:
            invalid_fields.append(key)
    if product_id is None:
        return error500()

    query = ds_client.query(kind='ProductCQRS')
    query.add_filter('product_id', '=', product_id)
    resp = None
    for result in query.fetch(): # This should return a single entity.
        resp = {
            'product_id': result['product_id'],
            'product_name': result['product_name'],
            'unit_price': result['unit_price'],
        }
        break
    if resp is None:
        return error500()

    return resp, 200


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
