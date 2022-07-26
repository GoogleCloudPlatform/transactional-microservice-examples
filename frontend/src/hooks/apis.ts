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

import { useState } from 'react';
import axios, { AxiosError } from 'axios';

export type CustomerResponse = {
  credit: number;
  customer_id: string;
  limit: number;
};

type OrderResponse = {
  customer_id: string;
  number: number;
  order_id: string;
  status: string;
};

type CreateCustomerRequest = {
  customer_id: string;
  limit: number;
};

const useApi = <T, K>() => {
  const [isError, setIsError] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isUnauthorizedError, setIsUnauthorizedError] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const post = async (url: string, token: string, payload: K): Promise<T> => {
    setIsUnauthorizedError(false);
    setIsLoading(true);
    setIsError(false);
    setIsSuccess(false);

    try {
      const response = await axios.post<T>(url, payload, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      setIsSuccess(true);
      return response.data;
    } catch (e: unknown) {
      const err = e as Error | AxiosError;
      if (axios.isAxiosError(err)) {
        if (err.response?.status === 401) {
          setIsUnauthorizedError(true);
        } else {
          setIsError(true);
        }
      } else {
        setIsError(true);
      }
      throw e;
    } finally {
      setIsLoading(false);
    }
  };

  return { isLoading, isSuccess, isError, isUnauthorizedError, post };
};

export const useCreateCustomer = () => {
  const { isLoading, post, isSuccess, isError, isUnauthorizedError } = useApi<
    CustomerResponse,
    CreateCustomerRequest
  >();

  const createCustomer = async (req: CreateCustomerRequest, token: string) => {
    const result = await post(
      '/customer-service-sync/api/v1/customer/limit',
      token,
      req,
    );
    // const result = await post('https://httpbin.org/delay/3', token, req);
    return result;
  };

  return {
    isLoading,
    isSuccess,
    isError,
    isUnauthorizedError,
    createCustomer,
  };
};

type GetOrderRequest = {
  customer_id: string;
  order_id: string;
};

export const useGetOrderAsync = () => {
  const { isLoading, post, isSuccess, isError, isUnauthorizedError } = useApi<
    OrderResponse,
    GetOrderRequest
  >();

  const getOrderAsync = async (req: GetOrderRequest, token: string) => {
    const result = await post(
      '/order-service-async/api/v1/order/get',
      token,
      req,
    );
    // const result = await post('https://httpbin.org/delay/3', token, req);
    return result;
  };

  return {
    isLoading,
    isSuccess,
    isError,
    isUnauthorizedError,
    getOrderAsync,
  };
};

type SubmitOrderRequest = {
  customer_id: string;
  number: number;
};

export const useSubmitOrderAsync = () => {
  const { isLoading, post, isSuccess, isError, isUnauthorizedError } = useApi<
    OrderResponse,
    SubmitOrderRequest
  >();

  const submitOrderAsync = async (req: SubmitOrderRequest, token: string) => {
    const result = await post(
      '/order-service-async/api/v1/order/create',
      token,
      req,
    );
    // const result = await post('https://httpbin.org/delay/3', token, req);
    return result;
  };

  return {
    isLoading,
    isSuccess,
    isError,
    isUnauthorizedError,
    submitOrderAsync,
  };
};

export const useSubmitOrderSync = () => {
  const { isLoading, post, isSuccess, isError, isUnauthorizedError } = useApi<
    OrderResponse,
    SubmitOrderRequest
  >();

  const submitOrderSync = async (req: SubmitOrderRequest, token: string) => {
    const result = await post(
      '/order-processor-service/api/v1/order/process',
      token,
      req,
    );
    // const result = await post('https://httpbin.org/delay/3', token, req);
    return result;
  };

  return {
    isLoading,
    isSuccess,
    isError,
    isUnauthorizedError,
    submitOrderSync,
  };
};

type GetCustomerRequest = {
  customer_id: string;
};

export const useGetCustomer = () => {
  const { isLoading, post, isSuccess, isError, isUnauthorizedError } = useApi<
    CustomerResponse,
    GetCustomerRequest
  >();

  const getCustomer = async (req: GetCustomerRequest, token: string) => {
    const result = await post(
      '/customer-service-sync/api/v1/customer/get',
      token,
      req,
    );
    // const result = await post('https://httpbin.org/delay/3', token, req);
    return result;
  };

  return {
    isLoading,
    isSuccess,
    isError,
    isUnauthorizedError,
    getCustomer,
  };
};
