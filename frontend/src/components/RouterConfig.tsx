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

import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import Checkout from '../pages/Checkout';
import First from '../pages/First';
import Navbar from './Navbar';
import Shop from '../pages/Shop';
import Orders from '../pages/Orders';
import { useCustomer } from '../context/CustomerContext';
import { useIdentityToken } from '../context/IdentityTokenContext';
import Profile from '../pages/Profile';

const RouterConfig = () => {
  const { customerId } = useCustomer();
  const { identityToken } = useIdentityToken();

  const isAuthenticated = () => customerId && identityToken;

  return (
    <BrowserRouter>
      <Routes>
        <Route
          path="/"
          element={
            isAuthenticated() ? (
              <Navbar>
                <Shop />
              </Navbar>
            ) : (
              <Navigate replace to="/first" />
            )
          }
        />
        <Route path="/about" element={<Navbar />} />
        <Route
          path="/checkout"
          element={
            isAuthenticated() ? (
              <Navbar>
                <Checkout />
              </Navbar>
            ) : (
              <Navigate replace to="/first" />
            )
          }
        />
        <Route
          path="/orders"
          element={
            isAuthenticated() ? (
              <Navbar>
                <Orders />
              </Navbar>
            ) : (
              <Navigate replace to="/first" />
            )
          }
        />
        <Route
          path="/profile"
          element={
            isAuthenticated() ? (
              <Navbar>
                <Profile />
              </Navbar>
            ) : (
              <Navigate replace to="/first" />
            )
          }
        />
        <Route path="/first" element={<First />} />
        <Route path="*" element={<Navigate replace to="/" />} />
      </Routes>
    </BrowserRouter>
  );
};

export default RouterConfig;
