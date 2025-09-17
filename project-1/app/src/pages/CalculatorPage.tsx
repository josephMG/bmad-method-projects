import React, { useEffect } from 'react';
import { Box, Paper, Grid, Typography } from '@mui/material';
import Display from '../features/calculator/components/Display';
import Keypad from '../features/calculator/components/Keypad';
import History from '../features/calculator/components/History';
import { useCalculator } from '../features/calculator/hooks/useCalculator';

const CalculatorPage: React.FC = () => {
  const { displayValue, history, handleNumberPress, handleOperatorPress, handleEqualsPress, handleClearPress, handleHistoryClick } = useCalculator();

  // Handle keyboard input
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (/[0-9]/.test(event.key)) {
        handleNumberPress(event.key);
      } else if (['+', '-', '*', '/'].includes(event.key)) {
        handleOperatorPress(event.key);
      } else if (event.key === 'Enter') {
        event.preventDefault(); // Prevent default form submission if any
        handleEqualsPress();
      } else if (event.key === 'Escape') {
        handleClearPress();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [handleNumberPress, handleOperatorPress, handleEqualsPress, handleClearPress]);

  return (
    <Box
      sx={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '100vh',
        backgroundColor: '#e0e0e0', // Light grey background for the page
      }}
    >
      <Paper
        elevation={6}
        sx={{
          width: { xs: '95%', sm: 400 }, // Responsive width
          padding: 2,
          borderRadius: 2,
          backgroundColor: '#ffffff', // White background for the calculator body
          display: 'flex',
          flexDirection: 'column',
        }}
      >
        {/* Display Component */}
        <Display value={displayValue} />

        {/* Keypad Component */}
        <Box sx={{ mb: 2 }}>
          <Keypad onButtonClick={handleNumberPress} onOperatorClick={handleOperatorPress} onEqualsClick={handleEqualsPress} onClearClick={handleClearPress} />
        </Box>

        {/* History Component */}
        <History history={history} onHistoryClick={handleHistoryClick} />
      </Paper>
    </Box>
  );
};

export default CalculatorPage;
