
'use client';

import { useRef } from 'react'; // Added useRef
import { Provider } from 'react-redux';
import { makeStore, AppStore } from './index'; // Changed import from store to makeStore and AppStore

export function ReduxProvider({ children }: { children: React.ReactNode }) {
  const storeRef = useRef<AppStore>();
  if (!storeRef.current) {
    // Create the store instance the first time this renders
    storeRef.current = makeStore();
  }

  return <Provider store={storeRef.current}>{children}</Provider>;
}
