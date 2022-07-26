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

import { BsCartFill } from 'react-icons/bs';
import { Link } from 'react-router-dom';
import { useCartItems } from '../context/CartContext';

const Cart = () => {
  const cartItems = useCartItems();

  return (
    <li className="relative mx-1 p-1 text-slate-800">
      <Link to="/checkout">
        <BsCartFill className="h-10 w-10 text-slate-500" />
        <p className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-sm font-bold text-white">
          {cartItems.reduce((total, item) => total + item.quantity, 0)}
        </p>
      </Link>
    </li>
  );
};
export default Cart;
