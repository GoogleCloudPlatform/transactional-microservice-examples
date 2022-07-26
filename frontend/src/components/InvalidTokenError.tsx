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

import { Link } from 'react-router-dom';

const InvalidTokenError = () => (
  <div className="my-6 border-2 border-red-500 p-3 text-center text-red-500">
    Identity token may be expired. Jump to{' '}
    <Link className="text-[#1a0dab]" to="/first">
      initial page
    </Link>{' '}
    and update the token.
  </div>
);

export default InvalidTokenError;
