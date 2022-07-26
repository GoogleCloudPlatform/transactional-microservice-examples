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

import { useState, FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import PulseLoader from 'react-spinners/PulseLoader';
import { MdContentCopy } from 'react-icons/md';
import { toast } from 'react-toastify';
import { useIdentityToken } from '../context/IdentityTokenContext';
import { useCustomer } from '../context/CustomerContext';
import { useCreateCustomer } from '../hooks/apis';
import { useCartItemsDispatch } from '../context/CartContext';
import { useOrdersDispatch } from '../context/OrdersContext';

const First = () => {
  const COMMAND = 'gcloud auth print-identity-token';
  const [token, setToken] = useState('');
  const [canProceed, setCanProceed] = useState(false);
  const dispatchCartItems = useCartItemsDispatch();
  const dispatchOrders = useOrdersDispatch();
  const { isLoading, isError, isUnauthorizedError, createCustomer } =
    useCreateCustomer();

  const navigate = useNavigate();
  const { setIdentityToken } = useIdentityToken();
  const { setCustomerId } = useCustomer();

  const handleTokenChange = (e: FormEvent<HTMLTextAreaElement>) => {
    if (e.currentTarget.value.length > 10) {
      setCanProceed(true);
    } else {
      setCanProceed(false);
    }
    setToken(e.currentTarget.value);
  };

  const getRandomInt = (max: number) => Math.floor(Math.random() * max);

  const generateRandomCustomerId = () =>
    `customer-${String(getRandomInt(999)).padStart(3, '0')}`;

  const handleClickProceed = async () => {
    const customerId = generateRandomCustomerId();
    try {
      await createCustomer({ customer_id: customerId, limit: 1000000 }, token);
      setIdentityToken(token);
      setCustomerId(customerId);
      dispatchCartItems({ type: 'reset' });
      dispatchOrders({ type: 'reset' });
      navigate('/');
      return;
    } catch (e) {
      console.error(e);
    }
    setToken('');
    setCanProceed(false);
  };

  const showCopySuccessMessage = () => {
    toast.info('Copied to clipboard', {
      position: 'bottom-left',
      autoClose: 1000,
      hideProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
      draggable: true,
      progress: undefined,
    });
  };

  const showCopyFailureMessage = () => {
    toast.error('Failed to copy', {
      position: 'bottom-left',
      autoClose: 1000,
      hideProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
      draggable: true,
      progress: undefined,
    });
  };

  const handleClickCopyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(COMMAND);
      showCopySuccessMessage();
    } catch (e) {
      showCopyFailureMessage();
    }
  };

  return (
    <div className="flex h-screen w-screen flex-col items-center justify-center">
      <div className="w-80 md:w-96">
        <h2 className="text-md mb-6 text-slate-800 md:text-lg">
          1. Run a following command in Cloud Shell.
        </h2>
        <div className="mb-10 flex items-center bg-slate-200 p-3">
          <p className="text-slate-700">{COMMAND}</p>
          <div className="mx-auto" />
          <button type="button" onClick={handleClickCopyToClipboard}>
            <MdContentCopy size={20} color="#334155" />
          </button>
        </div>
        <h2 className="text-md mb-6 text-slate-800 md:text-lg">
          2. Paste the output and click Proceed.
        </h2>
        <div className="mb-6 flex flex-col">
          <textarea
            id="token"
            className="border py-2 px-3 text-slate-700 shadow"
            value={token}
            onChange={handleTokenChange}
            rows={12}
          />
        </div>
        {isUnauthorizedError && (
          <div className="mb-6 border-2 border-red-500 p-3 text-center text-red-500">
            Identity token is invalid.
          </div>
        )}
        {isError && (
          <div className="mb-6 border-2 border-red-500 p-3 text-center text-red-500">
            Unknown error occured.
          </div>
        )}

        <button
          type="button"
          disabled={!canProceed || isLoading}
          className="w-full rounded bg-blue-500 p-3 text-white hover:bg-blue-700 disabled:bg-slate-300 disabled:text-slate-100"
          onClick={handleClickProceed}
        >
          {isLoading ? <PulseLoader color="#64748b" size={10} /> : 'Proceed'}
        </button>
      </div>
    </div>
  );
};

export default First;
