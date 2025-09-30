"use client";

import { useMemo, useEffect, useState } from 'react';
import { createTheme, ThemeProvider as MuiThemeProvider } from '@mui/material/styles';
import { useDispatch, useSelector } from 'react-redux';
import { RootState } from '@/store';
import { setTheme } from '@/store/theme/themeSlice';

const ThemeProvider = ({ children }: { children: React.ReactNode }) => {
  const dispatch = useDispatch();
  const { mode } = useSelector((state: RootState) => state.theme);
  const [isMounted, setIsMounted] = useState(false);

  // Effect to set the mounted state
  useEffect(() => {
    setIsMounted(true);
  }, []);

  // Determine and set the theme client-side if it's null (server-rendered)
  useEffect(() => {
    // Only run this on the client after mounting
    if (isMounted) {
      const storedTheme = localStorage.getItem('theme');
      const systemPreference = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
      const initialClientTheme = (storedTheme === 'light' || storedTheme === 'dark') ? storedTheme : systemPreference;
      
      // If the current mode in store is not the one we determined, dispatch an update
      if (mode !== initialClientTheme) {
        dispatch(setTheme(initialClientTheme));
      }
    }
  }, [isMounted, dispatch, mode]);

  useEffect(() => {
    if (mode === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [mode]);

  const theme = useMemo(() => {
    // Determine the effective mode, defaulting to 'light' on the server or before mounting
    const effectiveMode = isMounted ? mode : 'light';

    return createTheme({
      palette: {
        mode: effectiveMode || 'light', // Ensure mode is never null
        ...(effectiveMode === 'dark'
          ? {
              // Palette for dark mode
              primary: {
                main: '#90caf9', // Light blue
              },
              secondary: {
                main: '#f48fb1', // Pink
              },
              background: {
                default: '#121212', // Dark background
                paper: '#1e1e1e', // Slightly lighter dark background
              },
              text: {
                primary: '#ffffff', // White text
                secondary: '#aaaaaa', // Light gray secondary text
              },
            }
          : {
              // Palette for light mode
              primary: {
                main: '#1976d2', // Blue
              },
              secondary: {
                main: '#dc004e', // Red
              },
              background: {
                default: '#ffffff', // White background
                paper: '#f5f5f5', // Slightly darker light background
              },
              text: {
                primary: '#000000', // Black text
                secondary: '#555555', // Dark gray secondary text
              },
            }),
      },
    });
  }, [mode, isMounted]);

  return <MuiThemeProvider theme={theme}>{children}</MuiThemeProvider>;
};

export default ThemeProvider;
