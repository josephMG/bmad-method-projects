
import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { RootState } from '../index';

// 1. State Slice
interface AuthState {
  isAuthenticated: boolean;
  user: { id: string; email: string; } | null;
  token: string | null;
}

const initialState: AuthState = {
  isAuthenticated: false,
  user: null,
  token: null,
};

const authStateSlice = createSlice({
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
    },
    logout: (state) => {
      state.isAuthenticated = false;
      state.user = null;
      state.token = null;
    },
  },
});

export const { setCredentials, logout } = authStateSlice.actions;
export default authStateSlice.reducer;

export const selectIsAuthenticated = (state: RootState) => state.auth.isAuthenticated;
