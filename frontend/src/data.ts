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

import { CartItem } from './context/CartContext';
import { ProductType } from './types/productType';

export const products: ProductType[] = [
  {
    id: 1,
    name: 'T-shirts (white)',
    price: 50,
    image: '/images/01.png',
  },
  {
    id: 2,
    name: 'T-shirts (black)',
    price: 55,
    image: '/images/02.png',
  },
  {
    id: 3,
    name: 'T-shirts (red)',
    price: 55,
    image: '/images/03.png',
  },
  {
    id: 4,
    name: 'T-shirts (blue)',
    price: 55,
    image: '/images/04.png',
  },
  {
    id: 5,
    name: 'T-shirts (lime)',
    price: 55,
    image: '/images/05.png',
  },
  {
    id: 6,
    name: 'Shirts (sakura)',
    price: 70,
    image: '/images/06.png',
  },
  {
    id: 7,
    name: 'Shirts (seagreen)',
    price: 70,
    image: '/images/07.png',
  },
  {
    id: 8,
    name: 'Shirts (maroon)',
    price: 70,
    image: '/images/08.png',
  },
  {
    id: 9,
    name: 'Jacket (blue)',
    price: 250,
    image: '/images/09.png',
  },
  {
    id: 10,
    name: 'Coat (navy)',
    price: 300,
    image: '/images/10.png',
  },
  {
    id: 11,
    name: 'Jacket (black)',
    price: 500,
    image: '/images/11.png',
  },
];

export const getImageUrl = (id: number): string =>
  products.find((product) => product.id === id)?.image || '';

export const getName = (id: number): string =>
  products.find((product) => product.id === id)?.name || '';

export const getPrice = (id: number): number =>
  products.find((product) => product.id === id)?.price || 0;

export const totalPrice = (items: CartItem[]): number =>
  items.reduce(
    (total: number, cartItem) =>
      total + getPrice(cartItem.id) * cartItem.quantity,
    0,
  );
