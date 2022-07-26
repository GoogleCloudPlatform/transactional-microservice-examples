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

import { toast } from 'react-toastify';
import { ProductType } from '../types/productType';
import { useCartItemsDispatch } from '../context/CartContext';

type Props = {
  product: ProductType;
};

const Product = ({ product }: Props) => {
  const { name, image, price } = product;
  const dispatch = useCartItemsDispatch();

  const handleClickToCart = () => {
    toast.info('Added to cart', {
      position: 'bottom-left',
      autoClose: 500,
      hideProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
      draggable: true,
      progress: undefined,
    });
    dispatch({ type: 'add', payload: product.id });
  };

  return (
    <div className="mx-auto max-w-md rounded-lg border border-slate-100 bg-white">
      <img className="bg-slate-50 p-8" src={image} alt="" />
      <div className="p-5">
        <h5 className="mb-2 text-lg tracking-tight text-gray-600">{name}</h5>
        <div className="flex items-center justify-between">
          <span className="text-xl text-gray-800">$ {price}</span>
          <button
            type="button"
            onClick={handleClickToCart}
            className="rounded-lg border-2 border-slate-600 bg-white px-3 py-2 text-center text-sm text-slate-600 hover:cursor-pointer  hover:bg-slate-600 hover:text-white"
          >
            Add to cart
          </button>
        </div>
      </div>
    </div>
  );
};
export default Product;
