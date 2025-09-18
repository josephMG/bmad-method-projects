import React from 'react';
import { Box, Paper, Typography, Button } from '@mui/material';
import { styled } from '@mui/system';
import { useScientificCalculator } from '../features/calculator/hooks/useScientificCalculator';

const CalculatorPaper = styled(Paper)(({ theme }) => ({
  padding: theme.spacing(2),
  borderRadius: '12px',
  backgroundColor: '#2E2E2E',
  color: '#FFFFFF',
  width: '100%',
  maxWidth: '420px',
}));

const DisplayBox = styled(Box)({
  backgroundColor: '#1E1E1E',
  padding: '20px',
  textAlign: 'right',
  borderRadius: '8px',
  marginBottom: '16px',
  overflow: 'hidden',
  textOverflow: 'ellipsis',
  minHeight: '80px',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'flex-end',
});

const CalcButton = styled(Button)<{ button_variant?: 'operator' | 'function' }>(({ button_variant }) => ({
  height: '65px',
  fontSize: '1.5rem',
  borderRadius: '8px',
  backgroundColor: button_variant === 'operator' ? '#FF9500' : (button_variant === 'function' ? '#A5A5A5' : '#505050'),
  color: button_variant === 'function' ? '#000000' : '#FFFFFF',
  '&:hover': {
    backgroundColor: button_variant === 'operator' ? '#D97E00' : (button_variant === 'function' ? '#8C8C8C' : '#3D3D3D'),
  },
}));

const ScientificCalculatorPage: React.FC = () => {
  const { displayValue, handleNumberPress, handleDotPress, handleOperatorPress, handleEqualsPress, handleClearPress, handleScientificPress } = useScientificCalculator();

  return (
    <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh', backgroundColor: '#000000' }}>
      <CalculatorPaper elevation={12}>
        <DisplayBox>
          <Typography variant="h3">{displayValue}</Typography>
        </DisplayBox>
        <Box sx={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '8px' }}>
          <CalcButton button_variant="function" onClick={handleClearPress}>C</CalcButton>
          <CalcButton button_variant="function" onClick={() => handleScientificPress('x^2')}>x^2</CalcButton>
          <CalcButton button_variant="function" onClick={() => handleScientificPress('x^3')}>x^3</CalcButton>
          <CalcButton button_variant="operator" onClick={() => handleOperatorPress('/')}>/</CalcButton>

          <CalcButton button_variant="function" onClick={() => handleScientificPress('sin')}>sin</CalcButton>
          <CalcButton button_variant="function" onClick={() => handleScientificPress('cos')}>cos</CalcButton>
          <CalcButton button_variant="function" onClick={() => handleScientificPress('tan')}>tan</CalcButton>
          <CalcButton button_variant="operator" onClick={() => handleOperatorPress('*')}>*</CalcButton>

          <CalcButton onClick={() => handleNumberPress('7')}>7</CalcButton>
          <CalcButton onClick={() => handleNumberPress('8')}>8</CalcButton>
          <CalcButton onClick={() => handleNumberPress('9')}>9</CalcButton>
          <CalcButton button_variant="operator" onClick={() => handleOperatorPress('-')}>-</CalcButton>

          <CalcButton onClick={() => handleNumberPress('4')}>4</CalcButton>
          <CalcButton onClick={() => handleNumberPress('5')}>5</CalcButton>
          <CalcButton onClick={() => handleNumberPress('6')}>6</CalcButton>
          <CalcButton button_variant="operator" onClick={() => handleOperatorPress('+')}>+</CalcButton>

          <CalcButton onClick={() => handleNumberPress('1')}>1</CalcButton>
          <CalcButton onClick={() => handleNumberPress('2')}>2</CalcButton>
          <CalcButton onClick={() => handleNumberPress('3')}>3</CalcButton>
          <CalcButton button_variant="operator" sx={{ gridRow: 'span 2', height: '138px' }} onClick={handleEqualsPress}>=</CalcButton>

          <CalcButton sx={{ gridColumn: 'span 2' }} onClick={() => handleNumberPress('0')}>0</CalcButton>
          <CalcButton onClick={handleDotPress}>.</CalcButton>
        </Box>
      </CalculatorPaper>
    </Box>
  );
};

export default ScientificCalculatorPage;
