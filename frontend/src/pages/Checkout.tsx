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

import { BiPlus, BiMinus } from 'react-icons/bi';
import PulseLoader from 'react-spinners/PulseLoader';
import { useNavigate } from 'react-router-dom';
import { useCartItems, useCartItemsDispatch } from '../context/CartContext';
import { useCustomer } from '../context/CustomerContext';
import { useOrdersDispatch } from '../context/OrdersContext';
import { getImageUrl, getName, getPrice, totalPrice } from '../data';
import { useSubmitOrderAsync, useSubmitOrderSync } from '../hooks/apis';
import { useIdentityToken } from '../context/IdentityTokenContext';
import InvalidTokenError from '../components/InvalidTokenError';

const Checkout = () => {
  const { identityToken } = useIdentityToken();
  const cartItems = useCartItems();
  const dispatchCartItems = useCartItemsDispatch();
  const dispatchOrders = useOrdersDispatch();
  const { customerId } = useCustomer();
  const navigate = useNavigate();
  const {
    isLoading: isLoadingSync,
    isError: isErrorSync,
    isUnauthorizedError: isUnauthorizedErrorSync,
    submitOrderSync,
  } = useSubmitOrderSync();
  const {
    isLoading: isLoadingAsync,
    isError: isErrorAsync,
    isUnauthorizedError: isUnauthorizedErrorAsync,
    submitOrderAsync,
  } = useSubmitOrderAsync();

  const isLoading = () => isLoadingAsync || isLoadingSync;
  const isUnauthorizedError = () =>
    isUnauthorizedErrorAsync || isUnauthorizedErrorSync;
  const isError = () => isErrorAsync || isErrorSync;

  const kindsInCart = cartItems.length;

  const addToCart = (id: number) => {
    dispatchCartItems({ type: 'add', payload: id });
  };

  const removeFromCart = (id: number) => {
    dispatchCartItems({ type: 'remove', payload: id });
  };

  const resetCart = () => dispatchCartItems({ type: 'reset' });
  const handleClickSubmitOrderAsync = async () => {
    try {
      const order = await submitOrderAsync(
        { customer_id: customerId, number: totalPrice(cartItems) },
        identityToken,
      );
      dispatchOrders({
        type: 'add',
        payload: {
          order_id: order.order_id,
          isAsync: true,
          status: order.status,
          customer_id: customerId,
          cartItems,
        },
      });
      resetCart();
      navigate('/orders');
    } catch (e) {
      console.error(e);
    }
  };

  const handleClickSubmitOrderSync = async () => {
    try {
      const order = await submitOrderSync(
        { customer_id: customerId, number: totalPrice(cartItems) },
        identityToken,
      );
      dispatchOrders({
        type: 'add',
        payload: {
          order_id: order.order_id,
          isAsync: false,
          status: order.status,
          customer_id: customerId,
          cartItems,
        },
      });
      resetCart();
      navigate('/orders');
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <div className="m-auto max-w-5xl p-2">
      {cartItems.length !== 0 && (
        <p className="my-5 text-center text-xl text-slate-500">
          {kindsInCart} {kindsInCart >= 2 ? 'kinds' : 'kind'} in the cart
        </p>
      )}
      {cartItems.map((cartItem) => (
        <div key={cartItem.id} className="m-2 flex h-24 border-b-2 p-2">
          <img
            className="mr-3 bg-slate-50"
            src={getImageUrl(cartItem.id)}
            alt=""
          />
          <div className="mr-3 flex flex-col justify-around">
            <p className="text-lg text-gray-600">{getName(cartItem.id)}</p>
            <p className="text-xl text-gray-800">$ {getPrice(cartItem.id)}</p>
          </div>
          <div className="mx-auto" />
          <div className="my-auto flex w-40 items-center justify-end pr-2">
            <button type="button" onClick={() => addToCart(cartItem.id)}>
              <BiPlus className="h-8 w-8 text-slate-500" />
            </button>
            <p className="mx-2 w-10 text-center text-xl text-slate-500">
              {cartItem.quantity}
            </p>
            <button type="button" onClick={() => removeFromCart(cartItem.id)}>
              <BiMinus className="h-8 w-8 text-slate-500" />
            </button>
          </div>
        </div>
      ))}
      {cartItems.length !== 0 && (
        <>
          <div className="m-2 flex h-14 p-2">
            <div className="mx-auto" />
            <div className="flex justify-end border-b-2">
              <p className="mr-3 pl-4 text-xl text-slate-500">Total:</p>
              <div className="pr-4 text-xl text-slate-500">
                $ {totalPrice(cartItems)}
              </div>
            </div>
          </div>
          <div className="mb-6 flex">
            <button
              type="button"
              className="mx-auto mt-10 block w-48 rounded-lg border-2 border-slate-500 py-2 px-4 text-slate-600 hover:bg-slate-500 hover:text-white disabled:border-slate-300 disabled:bg-slate-300 disabled:text-slate-100"
              onClick={handleClickSubmitOrderAsync}
              disabled={isLoading()}
            >
              {isLoadingAsync ? (
                <PulseLoader color="#64748b" size={10} />
              ) : (
                'Submit order (Async)'
              )}
            </button>
            <button
              type="button"
              className="mx-auto mt-10 block w-48 rounded-lg border-2 border-slate-500 py-2 px-4 text-slate-600 hover:bg-slate-500 hover:text-white disabled:border-slate-300 disabled:bg-slate-300 disabled:text-slate-100"
              onClick={handleClickSubmitOrderSync}
              disabled={isLoading()}
            >
              {isLoadingSync ? (
                <PulseLoader color="#64748b" size={10} />
              ) : (
                'Submit order (Sync)'
              )}
            </button>
          </div>
        </>
      )}
      {cartItems.length === 0 && (
        <p className="pt-10 text-center text-xl text-slate-500">
          Currently no items in the cart!
        </p>
      )}
      {isUnauthorizedError() && <InvalidTokenError />}
      {isError() && (
        <div className="mb-6 border-2 border-red-500 p-3 text-center text-red-500">
          Unknown error occured.
        </div>
      )}
    </div>
  );
};

export default Checkout;
