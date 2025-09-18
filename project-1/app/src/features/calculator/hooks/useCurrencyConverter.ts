
import { useState } from 'react';

const RATES = {
  USD: 1,
  TWD: 32.3,
  JPY: 155.8,
  KRW: 1377.5,
};

type Currency = 'USD' | 'TWD'| 'JPY' | 'KRW';

export const useCurrencyConverter = () => {
  const [amount, setAmount] = useState(1);
  const [fromCurrency, setFromCurrency] = useState<Currency>('USD');
  const [toCurrency, setToCurrency] = useState<Currency>('TWD');
  const [isFromAmountSource, setIsFromAmountSource] = useState(true);

  const toRate = RATES[toCurrency];
  const fromRate = RATES[fromCurrency];

  let toAmount, fromAmount;
  if (isFromAmountSource) {
    fromAmount = amount;
    toAmount = amount * (toRate / fromRate);
  } else {
    toAmount = amount;
    fromAmount = amount * (fromRate / toRate);
  }

  const handleFromAmountChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = parseFloat(e.target.value);
    setIsFromAmountSource(true);
    setAmount(isNaN(value) ? 0 : value);
  };

  const handleToAmountChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = parseFloat(e.target.value);
    setIsFromAmountSource(false);
    setAmount(isNaN(value) ? 0 : value);
  };

  const handleFromCurrencyChange = (e: any) => { // Changed to any to avoid type issue with Select
    setFromCurrency(e.target.value as Currency);
  };

  const handleToCurrencyChange = (e: any) => { // Changed to any to avoid type issue with Select
    setToCurrency(e.target.value as Currency);
  };

  const swapCurrencies = () => {
    setFromCurrency(toCurrency);
    setToCurrency(fromCurrency);
  };

  return {
    fromAmount: fromAmount.toFixed(2),
    toAmount: toAmount.toFixed(2),
    fromCurrency,
    toCurrency,
    handleFromAmountChange,
    handleToAmountChange,
    handleFromCurrencyChange,
    handleToCurrencyChange,
    swapCurrencies,
    currencies: Object.keys(RATES) as Currency[],
  };
};
