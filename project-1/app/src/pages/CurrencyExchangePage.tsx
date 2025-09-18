import React from 'react';
import { Box, Paper, Grid, Typography, TextField, Select, MenuItem, IconButton } from '@mui/material';
import SwapHorizIcon from '@mui/icons-material/SwapHoriz';
import { useCurrencyConverter } from '../features/calculator/hooks/useCurrencyConverter';

const CurrencyExchangePage: React.FC = () => {
  const {
    fromAmount,
    toAmount,
    fromCurrency,
    toCurrency,
    handleFromAmountChange,
    handleToAmountChange,
    handleFromCurrencyChange,
    handleToCurrencyChange,
    swapCurrencies,
    currencies,
  } = useCurrencyConverter();

  return (
    <Box
      sx={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '100vh',
        backgroundColor: '#f0f0f0',
      }}
    >
      <Paper
        elevation={6}
        sx={{
          width: { xs: '95%', sm: 500 },
          padding: 3,
          borderRadius: 2,
          textAlign: 'center',
        }}
      >
        <Typography variant="h4" gutterBottom>
          Currency Converter
        </Typography>
        <Grid container spacing={2} alignItems="center" justifyContent="center">
          <Grid size={{ xs: 12, md: 5 }}>
            <TextField
              label="From"
              type="number"
              value={fromAmount}
              onChange={handleFromAmountChange}
              fullWidth
            />
          </Grid>
          <Grid size={{ xs: 12, md: 3 }}>
            <Select
              value={fromCurrency}
              onChange={handleFromCurrencyChange}
              fullWidth
            >
              {currencies.map((currency) => (
                <MenuItem key={currency} value={currency}>
                  {currency}
                </MenuItem>
              ))}
            </Select>
          </Grid>
        </Grid>
        
        <Box sx={{ margin: '20px 0' }}>
          <IconButton color="primary" onClick={swapCurrencies}>
            <SwapHorizIcon fontSize="large" />
          </IconButton>
        </Box>

        <Grid container spacing={2} alignItems="center" justifyContent="center">
          <Grid size={{ xs: 12, md: 5 }}>
            <TextField
              label="To"
              type="number"
              value={toAmount}
              onChange={handleToAmountChange}
              fullWidth
            />
          </Grid>
          <Grid size={{ xs: 12, md: 3 }}>
            <Select
              value={toCurrency}
              onChange={handleToCurrencyChange}
              fullWidth
            >
              {currencies.map((currency) => (
                <MenuItem key={currency} value={currency}>
                  {currency}
                </MenuItem>
              ))}
            </Select>
          </Grid>
        </Grid>
      </Paper>
    </Box>
  );
};

export default CurrencyExchangePage;