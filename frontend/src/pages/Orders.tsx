// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import { AiOutlineReload } from 'react-icons/ai';
import PulseLoader from 'react-spinners/PulseLoader';
import ClipLoader from 'react-spinners/ClipLoader';
import { useState } from 'react';
import { getImageUrl, getName, getPrice, totalPrice } from '../data';
import { useGetOrderAsync } from '../hooks/apis';
import { useCustomer } from '../context/CustomerContext';
import { useIdentityToken } from '../context/IdentityTokenContext';
import { useOrders, useOrdersDispatch } from '../context/OrdersContext';
import InvalidTokenError from '../components/InvalidTokenError';

const Orders = () => {
  const orders = useOrders();
  const dispatch = useOrdersDispatch();
  const [loadings, setLoadings] = useState(Array(orders.length).fill(false));

  const { customerId } = useCustomer();
  const { identityToken } = useIdentityToken();

  const { isLoading, isError, isUnauthorizedError, getOrderAsync } =
    useGetOrderAsync();

  const isCompleted = (isAsync: boolean, status: string) =>
    isAsync && status === 'pending';

  const handleClickUpdateOrder = async (
    orderId: string,
    id: number,
  ): Promise<void> => {
    try {
      setLoadings(
        loadings.map((loading, currentId) => {
          if (currentId === id) {
            return true;
          }
          return false;
        }),
      );
      const order = await getOrderAsync(
        { customer_id: customerId, order_id: orderId },
        identityToken,
      );
      dispatch({
        type: 'update',
        payload: {
          order_id: orderId,
          status: order.status,
        },
      });
    } catch (e) {
      console.error(e);
    } finally {
      setLoadings(Array(orders.length).fill(false));
    }
  };

  return (
    <div className="m-auto max-w-5xl p-2">
      {isUnauthorizedError && <InvalidTokenError />}
      {isError && (
        <div className="my-6 border-2 border-red-500 p-3 text-center text-red-500">
          Unknown error occured.
        </div>
      )}

      {orders.length !== 0 && (
        <p className="my-6 text-center text-xl text-slate-500">
          {orders.length} orders.
        </p>
      )}

      {orders.map((order, id) => (
        <div key={order.order_id} className="mb-4 rounded-md border">
          <div className="flex items-center gap-6 bg-slate-100 p-4">
            <div>
              <p className="text-md text-gray-600">Order ID</p>
              <p className="text-lg text-gray-600">{order.order_id}</p>
            </div>
            <div>
              <p className="text-md text-gray-600">Status</p>

              {loadings[id] ? (
                <p className="text-lg text-gray-600">
                  <PulseLoader color="#64748b" size={10} />
                </p>
              ) : (
                <p className="text-lg text-gray-600">{order.status}</p>
              )}
            </div>
            <div>
              <p className="text-md text-gray-600">Total</p>
              <p className="text-lg text-gray-600">
                $ {totalPrice(order.cartItems)}
              </p>
            </div>
            <div className="mx-auto" />
            {isCompleted(order.isAsync, order.status) && (
              <button
                onClick={() => handleClickUpdateOrder(order.order_id, id)}
                type="button"
                disabled={isLoading}
              >
                {isLoading && loadings[id] ? (
                  <ClipLoader size="32px" color="#64748b" />
                ) : (
                  <AiOutlineReload className="h-8 w-8 align-middle text-slate-500" />
                )}
              </button>
            )}
          </div>
          {order.cartItems.map((cartItem, itemId) => (
            <div
              key={cartItem.id}
              className={`m-2 flex h-24 p-2 ${
                itemId !== order.cartItems.length - 1 ? 'border-b-2' : ''
              }`}
            >
              <img
                className="mr-3 bg-slate-50"
                src={getImageUrl(cartItem.id)}
                alt=""
              />
              <div className="mr-3 flex flex-col justify-around">
                <p className="text-lg text-gray-600">{getName(cartItem.id)}</p>
                <div className="flex gap-4">
                  <p className="text-xl text-gray-800">
                    $ {getPrice(cartItem.id)}
                  </p>
                  <p className="text-xl text-gray-800">×</p>
                  <p className="text-xl text-gray-600">{cartItem.quantity}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      ))}
      {orders.length === 0 && (
        <p className="pt-10 text-center text-xl text-slate-500">
          Currently no orders!
        </p>
      )}
    </div>
  );
};

export default Orders;
