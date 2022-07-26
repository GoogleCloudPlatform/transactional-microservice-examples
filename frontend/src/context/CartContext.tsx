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

import {
  createContext,
  useContext,
  ReactNode,
  useReducer,
  Dispatch,
} from 'react';

export type CartItem = {
  id: number;
  quantity: number;
};

type Props = {
  children: ReactNode;
};

type ACTIONTYPE =
  | { type: 'add'; payload: number }
  | { type: 'remove'; payload: number }
  | { type: 'reset' };

const CartItemsContext = createContext([] as CartItem[]);
const CartItemsDispatchContext = createContext<Dispatch<ACTIONTYPE>>(() => {
  // Initial
});

const cartItemsReducer = (cartItems: CartItem[], action: ACTIONTYPE) => {
  switch (action.type) {
    case 'add':
      if (
        cartItems.find((cartItem) => cartItem.id === action.payload) == null
      ) {
        return [...cartItems, { id: action.payload, quantity: 1 }];
      }
      return cartItems.map((cartItem) => {
        if (cartItem.id === action.payload)
          return { ...cartItem, quantity: cartItem.quantity + 1 };
        return cartItem;
      });
    case 'remove':
      if (
        cartItems.find((cartItem) => cartItem.id === action.payload)
          ?.quantity === 1
      ) {
        return cartItems.filter((cartItem) => cartItem.id !== action.payload);
      }
      return cartItems.map((cartItem) => {
        if (cartItem.id === action.payload)
          return { ...cartItem, quantity: cartItem.quantity - 1 };
        return cartItem;
      });
    case 'reset':
      return [];
    default:
      throw new Error();
  }
};

export const CartProvider = ({ children }: Props) => {
  const [cartItems, dispatch] = useReducer(cartItemsReducer, [] as CartItem[]);

  return (
    <CartItemsContext.Provider value={cartItems}>
      <CartItemsDispatchContext.Provider value={dispatch}>
        {children}
      </CartItemsDispatchContext.Provider>
    </CartItemsContext.Provider>
  );
};

export const useCartItems = () => useContext(CartItemsContext);
export const useCartItemsDispatch = () => useContext(CartItemsDispatchContext);
