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

import { useEffect, useState } from 'react';
import { FaUser } from 'react-icons/fa';
import PulseLoader from 'react-spinners/PulseLoader';
import { useCustomer } from '../context/CustomerContext';
import { CustomerResponse, useGetCustomer } from '../hooks/apis';
import { useIdentityToken } from '../context/IdentityTokenContext';
import InvalidTokenError from '../components/InvalidTokenError';

type CustomerType = CustomerResponse | null;

const Profile = () => {
  const [customerState, setCustomerState] = useState<CustomerType>(null);

  const { isError, isUnauthorizedError, isLoading, getCustomer } =
    useGetCustomer();
  const { customerId } = useCustomer();
  const { identityToken } = useIdentityToken();

  useEffect(() => {
    const fetchCustomerInformation = async () => {
      try {
        const customer = await getCustomer(
          { customer_id: customerId },
          identityToken,
        );
        setCustomerState(customer);
      } catch (e) {
        console.error(e);
      }
    };
    // eslint-disable-next-line @typescript-eslint/no-floating-promises
    fetchCustomerInformation();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [customerId, identityToken]);

  const adjustNumberToPrice = (num: number) => num / 100;

  return (
    <div className="m-auto max-w-5xl p-2">
      {isUnauthorizedError && <InvalidTokenError />}
      {isError && (
        <div className="my-6 border-2 border-red-500 p-3 text-center text-red-500">
          Unknown error occured.
        </div>
      )}

      <div className="flex w-full items-center">
        <div className="mr-2 bg-white p-6">
          <FaUser size="120" color="#64748b" />
        </div>
        <div className="grow">
          {isLoading ? (
            <PulseLoader />
          ) : (
            <div className="flex items-center gap-4 border-slate-300 p-4">
              <div className="w-24">
                <div className="text-md text-gray-600">Remaining</div>
                <div className="text-lg text-gray-600">
                  {customerState?.limit
                    ? `$ ${adjustNumberToPrice(
                        customerState.limit - customerState.credit,
                      )}`
                    : 'N/A'}
                </div>
              </div>
              <div className="w-24">
                <div className="text-md text-gray-600">Used</div>
                <div className="text-lg text-gray-600">
                  {customerState?.limit
                    ? `$ ${adjustNumberToPrice(customerState.credit)}`
                    : 'N/A'}
                </div>
              </div>
              <div className="w-24">
                <div className="text-md text-gray-600">Budget</div>
                <div className="text-lg text-gray-600">
                  {customerState?.limit
                    ? `$ ${adjustNumberToPrice(customerState.limit)}`
                    : 'N/A'}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Profile;
