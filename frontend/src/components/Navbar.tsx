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

import { ReactNode } from 'react';
import { Link } from 'react-router-dom';
import { useCustomer } from '../context/CustomerContext';
import Cart from './Cart';

type Props = {
  children?: ReactNode | null;
};

const Navbar = ({ children }: Props) => {
  const { customerId } = useCustomer();
  return (
    <>
      <nav className="sticky top-0 bg-slate-200">
        <ul className="flex items-center justify-between p-3">
          <li className="mx-1 p-1 font-prata text-xl text-slate-600">
            <Link to="/">Awesome Clothes</Link>
          </li>
          <li>
            <ul className="flex items-center">
              <li className="mx-1 p-1 text-slate-600">
                <Link to="/orders">Orders</Link>
              </li>
              <li className="mx-1 p-1 text-slate-600">
                <Link to="/profile">{customerId}</Link>
              </li>
              <Cart />
            </ul>
          </li>
        </ul>
      </nav>
      {children && children}
    </>
  );
};

Navbar.defaultProps = {
  children: null,
};

export default Navbar;
