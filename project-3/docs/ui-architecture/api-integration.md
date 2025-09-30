# API Integration

### Service Template

```typescript
// src/store/auth/authApi.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

interface LoginRequest {
  email: string;
  password: string;
}

interface LoginResponse {
  access_token: string;
  token_type: string;
  user: { id: string; email: string };
}

export const authApi = createApi({
  reducerPath: 'authApi',
  baseQuery: fetchBaseQuery({
    baseUrl: process.env.NEXT_PUBLIC_API_BASE_URL, // Assuming this env var is set
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token; // Access token from auth slice
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  endpoints: (builder) => ({
    login: builder.mutation<LoginResponse, LoginRequest>({
      query: (credentials) => ({
        url: '/token', // Assuming /api/v1/token is the full path
        method: 'POST',
        body: credentials,
      }),
      async onQueryStarted(credentials, { dispatch, queryFulfilled }) {
        try {
          const { data } = await queryFulfilled;
          dispatch(authSlice.actions.setCredentials({ user: data.user, token: data.access_token }));
        } catch (error) {
          dispatch(authSlice.actions.setError('Login failed'));
        }
      },
    }),
    getProfile: builder.query<{ id: string; email: string }, void>({
      query: () => '/users/me', // Assuming /api/v1/users/me is the full path
    }),
    register: builder.mutation<any, any>({ // Define appropriate types for request and response
      query: (userData) => ({
        url: '/register', // Assuming /api/v1/register is the full path
        method: 'POST',
        body: userData,
      }),
    }),
  }),
});

export const { useLoginMutation, useGetProfileQuery, useRegisterMutation } = authApi;
```

### API Client Configuration

```typescript
// Example from src/store/auth/authApi.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import { RootState } from '../index'; // Assuming RootState is defined

export const baseQuery = fetchBaseQuery({
  baseUrl: process.env.NEXT_PUBLIC_API_BASE_URL, // Base URL from environment variable
  prepareHeaders: (headers, { getState }) => {
    const token = (getState() as RootState).auth.token; // Get token from Redux store
    if (token) {
      headers.set('authorization', `Bearer ${token}`); // Attach token for authenticated requests
    }
    return headers;
  },
});

// Example of a custom baseQuery with global error handling (optional)
// const baseQueryWithReauth: BaseQueryFn<
//   string | FetchArgs,
//   unknown,
//   FetchBaseQueryError
// > = async (args, api, extraOptions) => {
//   let result = await baseQuery(args, api, extraOptions);
//   if (result.error && result.error.status === 401) {
//     // try to get a new token
//     // const refreshResult = await baseQuery('/refreshToken', api, extraOptions);
//     // if (refreshResult.data) {
//     //   api.dispatch(tokenReceived(refreshResult.data));
//     //   // retry the original query with new access token
//     //   result = await baseQuery(args, api, extraOptions);
//     // }
//   }
//   return result;
// };

// Then use baseQueryWithReauth in createApi:
// export const authApi = createApi({
//   reducerPath: 'authApi',
//   baseQuery: baseQueryWithReauth,
//   endpoints: (builder) => ({ ... }),
// });
```