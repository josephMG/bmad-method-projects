'use client';

import * as React from 'react';
import createCache from '@emotion/cache';
import { CacheProvider as DefaultCacheProvider } from '@emotion/react';
import type { EmotionCache, Options as EmotionCacheOptions } from '@emotion/cache';

export interface EmotionCacheProviderProps {
  options: EmotionCacheOptions;
  children: React.ReactNode;
}

const defaultCache = createCache({ key: 'mui', prepend: true });

export default function EmotionCacheProvider(props: EmotionCacheProviderProps) {
  const { options, children } = props;

  const [emotionCache] = React.useState<EmotionCache>(() => {
    return createCache(options);
  });

  return (
    <DefaultCacheProvider value={emotionCache}>
      {children}
    </DefaultCacheProvider>
  );
}
