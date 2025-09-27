# State Management

### Store Structure

```plaintext
src/
├── store/
│   ├── index.ts            # Redux store configuration
│   ├── hooks.ts            # Typed Redux hooks (useAppDispatch, useAppSelector)
│   ├── auth/               # Auth feature slice
│   │   ├── authSlice.ts    # Auth reducer, actions, selectors
│   │   └── authApi.ts      # RTK Query API slice for auth
│   ├── user/               # User feature slice
│   │   ├── userSlice.ts    # User reducer, actions, selectors
│   │   └── userApi.ts      # RTK Query API slice for user
│   ├── common/             # Common/global slices (e.g., notifications)
│   │   └── notificationSlice.ts
│   └── types.ts            # Global Redux types
```

### State Management Template

```typescript
// src/store/auth/authSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { RootState } from '../index'; // Assuming RootState is defined in src/store/index.ts

interface AuthState {
  isAuthenticated: boolean;
  user: { id: string; email: string } | null;
  token: string | null;
  isLoading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  isAuthenticated: false,
  user: null,
  token: null,
  isLoading: false,
  error: null,
};

export const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setCredentials: (
      state,
      action: PayloadAction<{ user: { id: string; email: string }; token: string }>
    ) => {
      state.isAuthenticated = true;
      state.user = action.payload.user;
      state.token = action.payload.token;
      state.isLoading = false;
      state.error = null;
    },
    logout: (state) => {
      state.isAuthenticated = false;
      state.user = null;
      state.token = null;
      state.isLoading = false;
      state.error = null;
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
  },
  // Extra reducers for handling RTK Query lifecycle actions
  extraReducers: (builder) => {
    // Example: Handle pending/fulfilled/rejected states from an RTK Query endpoint
    // builder.addMatcher(authApi.endpoints.login.matchPending, (state) => {
    //   state.isLoading = true;
    // });
    // builder.addMatcher(authApi.endpoints.login.matchFulfilled, (state, action) => {
    //   state.isLoading = false;
    //   state.isAuthenticated = true;
    //   state.user = action.payload.user;
    //   state.token = action.payload.token;
    // });
    // builder.addMatcher(authApi.endpoints.login.matchRejected, (state, action) => {
    //   state.isLoading = false;
    //   state.error = action.error?.message || 'Login failed';
    // });
  },
});

export const { setCredentials, logout, setLoading, setError } = authSlice.actions;

export const selectIsAuthenticated = (state: RootState) => state.auth.isAuthenticated;
export const selectCurrentUser = (state: RootState) => state.auth.user;
export const selectAuthToken = (state: RootState) => state.auth.token;
export const selectAuthLoading = (state: RootState) => state.auth.isLoading;
export const selectAuthError = (state: RootState) => state.auth.error;

export default authSlice.reducer;
```

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
  endpoints: (builder) => {
    // Example: login mutation
    login: builder.mutation<LoginResponse, LoginRequest>({
      query: (credentials) => ({
        url: '/token',
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
    // Example: get user profile query
    getProfile: builder.query<{ id: string; email: string }, void>({
      query: () => '/users/me',
    }),
  },
});

export const { useLoginMutation, useGetProfileQuery } = authApi;
```