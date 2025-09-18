
import { useState } from 'react';

export const useScientificCalculator = () => {
  const [displayValue, setDisplayValue] = useState('0');
  const [operator, setOperator] = useState<string | null>(null);
  const [previousValue, setPreviousValue] = useState<number | null>(null);
  const [waitingForOperand, setWaitingForOperand] = useState(true);

  const factorial = (n: number): number => {
    if (n < 0) return NaN; // Or throw an error
    if (n > 20) return Infinity; // Prevent stack overflow and large numbers
    if (n === 0) return 1;
    return n * factorial(n - 1);
  };

  const handleNumberPress = (number: string) => {
    if (waitingForOperand) {
      setDisplayValue(number);
      setWaitingForOperand(false);
    } else {
      setDisplayValue(displayValue === '0' ? number : displayValue + number);
    }
  };

  const handleDotPress = () => {
    if (waitingForOperand) {
      setDisplayValue('0.');
      setWaitingForOperand(false);
    } else if (!displayValue.includes('.')) {
      setDisplayValue(displayValue + '.');
    }
  };

  const performOperation = (nextOperator: string) => {
    const inputValue = parseFloat(displayValue);

    if (previousValue === null) {
      setPreviousValue(inputValue);
    } else if (operator) {
      const result = calculate(previousValue, inputValue, operator);
      setPreviousValue(result);
      setDisplayValue(String(result));
    }

    setWaitingForOperand(true);
    setOperator(nextOperator);
  };
  
  const calculate = (firstOperand: number, secondOperand: number, op: string) => {
      switch (op) {
        case '+': return firstOperand + secondOperand;
        case '-': return firstOperand - secondOperand;
        case '*': return firstOperand * secondOperand;
        case '/': return firstOperand / secondOperand;
        case '^': return Math.pow(firstOperand, secondOperand);
        default: return secondOperand;
      }
  }

  const handleOperatorPress = (nextOperator: string) => {
    performOperation(nextOperator);
  };

  const handleEqualsPress = () => {
    if (operator && previousValue !== null) {
        const inputValue = parseFloat(displayValue);
        const result = calculate(previousValue, inputValue, operator);
        setDisplayValue(String(result));
        setPreviousValue(null);
        setOperator(null);
        setWaitingForOperand(true);
    }
  };

  const handleClearPress = () => {
    setDisplayValue('0');
    setOperator(null);
    setPreviousValue(null);
    setWaitingForOperand(true);
  };

  const handleScientificPress = (func: string) => {
    const current = parseFloat(displayValue);
    let result: number;
    switch (func) {
      case 'sin': result = Math.sin(current); break;
      case 'cos': result = Math.cos(current); break;
      case 'tan': result = Math.tan(current); break;
      case 'log': result = Math.log10(current); break;
      case 'ln': result = Math.log(current); break;
      case 'sqrt': result = Math.sqrt(current); break;
      case '!': result = factorial(current); break;
      case 'x^2': result = Math.pow(current, 2); break;
      case 'x^3': result = Math.pow(current, 3); break;
      default: return;
    }
    setDisplayValue(String(result));
    setWaitingForOperand(true);
  };

  return {
    displayValue,
    handleNumberPress,
    handleDotPress,
    handleOperatorPress,
    handleEqualsPress,
    handleClearPress,
    handleScientificPress,
  };
};
