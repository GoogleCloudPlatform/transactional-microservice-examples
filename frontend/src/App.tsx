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

import { ToastContainer } from 'react-toastify';
import RouterConfig from './components/RouterConfig';
import { IdentityTokenProvider } from './context/IdentityTokenContext';
import { CartProvider } from './context/CartContext';
import { CustomerProvider } from './context/CustomerContext';
import { OrdersProvider } from './context/OrdersContext';
import 'react-toastify/dist/ReactToastify.min.css';

const App = () => (
  <CustomerProvider>
    <IdentityTokenProvider>
      <OrdersProvider>
        <CartProvider>
          <ToastContainer />
          <RouterConfig />
        </CartProvider>
      </OrdersProvider>
    </IdentityTokenProvider>
  </CustomerProvider>
);

export default App;
