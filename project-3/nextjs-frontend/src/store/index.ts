import { configureStore } from "@reduxjs/toolkit";
import authReducer from "./auth/authSlice";
import userReducer from "./user/userSlice";
import themeReducer from "./theme/themeSlice";
import { authApi } from "./auth/authApi"; // Added import for authApi
import { userApi } from "./user/userApi";

export const makeStore = () => {
  return configureStore({
    reducer: {
      auth: authReducer,
      user: userReducer,
      theme: themeReducer,
      [authApi.reducerPath]: authApi.reducer, // Added authApi reducer
      [userApi.reducerPath]: userApi.reducer, // Added userApi reducer
    },
    middleware: (getDefaultMiddleware) =>
      getDefaultMiddleware().concat(authApi.middleware, userApi.middleware), // Added authApi middleware
  });
};

export type AppStore = ReturnType<typeof makeStore>;
export type RootState = ReturnType<AppStore["getState"]>;
export type AppDispatch = AppStore["dispatch"];
