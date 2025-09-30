"use client";

import { IconButton } from '@mui/material';
import Brightness4 from '@mui/icons-material/Brightness4';
import Brightness7 from '@mui/icons-material/Brightness7';
import { useDispatch, useSelector } from 'react-redux';
import { RootState } from '@/store';
import { toggleTheme } from '@/store/theme/themeSlice';
import { useState, useEffect } from 'react'; // Added useState and useEffect

const ThemeToggleButton = () => {
  const dispatch = useDispatch();
  const { mode } = useSelector((state: RootState) => state.theme);
  const [mounted, setMounted] = useState(false); // New state for client-side mounting

  useEffect(() => {
    setMounted(true); // Set mounted to true after initial render on the client
  }, []);

  const handleToggle = () => {
    dispatch(toggleTheme());
  };

  if (!mounted) {
    return null; // Render nothing on the server and until mounted on client
  }

  return (
    <IconButton onClick={handleToggle} color="inherit">
      {mode === 'dark' ? <Brightness7 /> : <Brightness4 />}
    </IconButton>
  );
};

export default ThemeToggleButton;
