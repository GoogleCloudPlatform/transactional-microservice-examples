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
  Dispatch,
  ReactNode,
  useReducer,
  useContext,
} from 'react';
import { CartItem } from './CartContext';

export type Order = {
  customer_id: string;
  order_id: string;
  status: string;
  isAsync: boolean;
  cartItems: CartItem[];
};

type OrderUpdate = {
  order_id: string;
  status: string;
};

type ACTIONTYPE =
  | { type: 'add'; payload: Order }
  | { type: 'update'; payload: OrderUpdate }
  | { type: 'reset' };

type Props = {
  children: ReactNode;
};

const OrdersContext = createContext([] as Order[]);
const OrdersDispatchContext = createContext<Dispatch<ACTIONTYPE>>(() => {
  // Initial
});

const ordersReducer = (orders: Order[], action: ACTIONTYPE) => {
  switch (action.type) {
    case 'add':
      return [action.payload, ...orders];
    case 'update':
      return orders.map((order) => {
        if (order.order_id === action.payload.order_id)
          return { ...order, status: action.payload.status };
        return order;
      });
    case 'reset':
      return [];
    default:
      throw new Error();
  }
};

export const OrdersProvider = ({ children }: Props) => {
  const [orders, dispatch] = useReducer(ordersReducer, [] as Order[]);
  return (
    <OrdersContext.Provider value={orders}>
      <OrdersDispatchContext.Provider value={dispatch}>
        {children}
      </OrdersDispatchContext.Provider>
    </OrdersContext.Provider>
  );
};

export const useOrders = () => useContext(OrdersContext);
export const useOrdersDispatch = () => useContext(OrdersDispatchContext);
