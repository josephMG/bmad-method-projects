
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
export const userApi = createApi({
  reducerPath: 'userApi',
  baseQuery: fetchBaseQuery({
    baseUrl: process.env.NEXT_PUBLIC_API_BASE_URL,
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as any).auth.token;
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  endpoints: (builder) => ({
    getUserProfile: builder.query<UserRead, void>({
      query: () => 'users/me',
    }),
    updateUserProfile: builder.mutation<UserRead, UserUpdate>({
      query: (body) => ({
        url: 'users/me',
        method: 'PUT',
        body,
      }),
    }),
    changePassword: builder.mutation<void, PasswordUpdate>({
      query: (body) => ({
        url: 'users/me/password',
        method: 'PUT',
        body,
      }),
    }),
    deleteUserAccount: builder.mutation<void, void>({
      query: () => ({
        url: 'users/me',
        method: 'DELETE',
      }),
    }),
  }),
});

export const { useGetUserProfileQuery, useUpdateUserProfileMutation, useChangePasswordMutation, useDeleteUserAccountMutation } = userApi;
