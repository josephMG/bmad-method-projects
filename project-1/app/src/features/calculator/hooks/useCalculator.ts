import { useState } from 'react';

export interface CalculatorState {
  displayValue: string;
  history: string[];
}

const calculate = (firstOperand: number, secondOperand: number, operator: string): number | string => {
  switch (operator) {
    case '+': return firstOperand + secondOperand;
    case '-': return firstOperand - secondOperand;
    case '*': return firstOperand * secondOperand;
    case '/':
      if (secondOperand === 0) return 'Error'; // Division by zero
      return firstOperand / secondOperand;
    default: return secondOperand;
  }
};

export const useCalculator = () => {
  const [displayValue, setDisplayValue] = useState<string>('0');
  const [history, setHistory] = useState<string[]>([]);
  const [firstOperand, setFirstOperand] = useState<number | null>(null);
  const [operator, setOperator] = useState<string | null>(null);
  const [waitingForSecondOperand, setWaitingForSecondOperand] = useState<boolean>(false);
  const [prevDisplayValue, setPrevDisplayValue] = useState<string | null>(null); // To store the display value before operator press

  const handleNumberPress = (num: string) => {
    if (displayValue === 'Error') {
      setDisplayValue(num);
      setWaitingForSecondOperand(false);
      setFirstOperand(null);
      setOperator(null);
      setPrevDisplayValue(null);
      return;
    }

    if (waitingForSecondOperand) {
      setDisplayValue(num);
      setWaitingForSecondOperand(false);
    } else {
      if (displayValue === '0' && num === '0') {
        return;
      }
      if (displayValue === '0' && num !== '0' && num !== '.') {
        setDisplayValue(num);
      } else {
        setDisplayValue((prev) => prev + num);
      }
    }
  };

  const handleOperatorPress = (nextOperator: string) => {
    const inputValue = parseFloat(displayValue);

    if (firstOperand === null) {
      setFirstOperand(inputValue);
      setPrevDisplayValue(displayValue); // Store current display value as part of the equation
    } else if (operator) {
      const result = calculate(firstOperand, inputValue, operator);
      if (result === 'Error') {
        setDisplayValue('Error');
        setFirstOperand(null);
        setOperator(null);
        setWaitingForSecondOperand(false);
        setPrevDisplayValue(null);
        return;
      }
      setDisplayValue(String(result));
      setFirstOperand(Number(result));
      setPrevDisplayValue(String(result)); // Store result for chained operation history
    }

    setWaitingForSecondOperand(true);
    setOperator(nextOperator);
  };

  const handleEqualsPress = () => {
    const inputValue = parseFloat(displayValue);

    if (firstOperand === null || operator === null) {
      return;
    }

    const result = calculate(firstOperand, inputValue, operator);

    let equation = '';
    if (prevDisplayValue !== null) {
      equation = `${prevDisplayValue} ${operator} ${displayValue} = ${result}`;
    } else {
      equation = `${firstOperand} ${operator} ${displayValue} = ${result}`;
    }

    if (result === 'Error') {
      setDisplayValue('Error');
    } else {
      setDisplayValue(String(result));
      setHistory((prevHistory) => [equation, ...prevHistory]); // Add to history
    }

    setFirstOperand(null);
    setOperator(null);
    setWaitingForSecondOperand(false);
    setPrevDisplayValue(null);
  };

  const handleClearPress = () => {
    setDisplayValue('0');
    setFirstOperand(null);
    setOperator(null);
    setWaitingForSecondOperand(false);
    setPrevDisplayValue(null);
  };

  const handleHistoryClick = (value: string) => {
    setDisplayValue(value);
    setFirstOperand(null);
    setOperator(null);
    setWaitingForSecondOperand(false);
    setPrevDisplayValue(null);
  };

  return {
    displayValue,
    history,
    handleNumberPress,
    handleOperatorPress,
    handleEqualsPress,
    handleClearPress,
    handleHistoryClick,
  };
};