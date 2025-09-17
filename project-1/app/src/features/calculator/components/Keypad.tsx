import React from 'react';
import { Button, Grid } from '@mui/material';

interface KeypadProps {
  onButtonClick: (value: string) => void;
  onClearClick: () => void;
  onOperatorClick: (operator: string) => void;
  onEqualsClick: () => void;
}

const Keypad: React.FC<KeypadProps> = ({ onButtonClick, onClearClick, onOperatorClick, onEqualsClick }) => {
  const buttons = [
    { label: 'C', type: 'clear', xs: 3 },
    { label: '', type: 'empty', xs: 3 }, // Placeholder
    { label: '', type: 'empty', xs: 3 }, // Placeholder
    { label: '/', type: 'operator', xs: 3 },

    { label: '7', type: 'number', xs: 3 },
    { label: '8', type: 'number', xs: 3 },
    { label: '9', type: 'number', xs: 3 },
    { label: '*', type: 'operator', xs: 3 },

    { label: '4', type: 'number', xs: 3 },
    { label: '5', type: 'number', xs: 3 },
    { label: '6', type: 'number', xs: 3 },
    { label: '-', type: 'operator', xs: 3 },

    { label: '1', type: 'number', xs: 3 },
    { label: '2', type: 'number', xs: 3 },
    { label: '3', type: 'number', xs: 3 },
    { label: '+', type: 'operator', xs: 3 },

    { label: '0', type: 'number', xs: 6 }, // Spans 2 columns
    { label: '.', type: 'decimal', xs: 3 },
    { label: '=', type: 'equals', xs: 3 },
  ];

  const getButtonColor = (type: string) => {
    switch (type) {
      case 'clear': return 'error';
      case 'operator': return 'primary';
      case 'equals': return 'success';
      default: return 'inherit';
    }
  };

  const getButtonBgColor = (type: string) => {
    switch (type) {
      case 'clear': return '#f44336';
      case 'operator': return '#1976d2';
      case 'equals': return '#4caf50';
      case 'empty': return 'transparent';
      default: return '#e0e0e0';
    }
  };

  const getButtonHoverBgColor = (type: string) => {
    switch (type) {
      case 'clear': return '#d32f2f';
      case 'operator': return '#1565c0';
      case 'equals': return '#43a047';
      case 'empty': return 'transparent';
      default: return '#c0c0c0';
    }
  };

  const getButtonTextColor = (type: string) => {
    switch (type) {
      case 'clear':
      case 'operator':
      case 'equals': return '#ffffff';
      case 'empty': return 'transparent';
      default: return '#000000';
    }
  };

  const handleClick = (label: string, type: string) => {
    if (type === 'clear') {
      onClearClick();
    } else if (type === 'equals') {
      onEqualsClick();
    } else if (type === 'operator') {
      onOperatorClick(label);
    } else if (type !== 'empty') {
      onButtonClick(label);
    }
  };

  return (
    <Grid container spacing={1} justifyContent="center">
      {buttons.map((button) => (
        <Grid item key={button.label} size={button.xs}> 
          <Button
            variant="contained"
            disabled={button.type === 'empty'} // Disable empty buttons
            color={getButtonColor(button.type)}
            sx={{
              width: '100%',
              height: 60,
              fontSize: '1.5rem',
              backgroundColor: getButtonBgColor(button.type),
              color: getButtonTextColor(button.type),
              '&:hover': {
                backgroundColor: getButtonHoverBgColor(button.type),
              },
            }}
            onClick={() => handleClick(button.label, button.type)} // Use new handleClick
          >
            {button.label}
          </Button>
        </Grid>
      ))}
    </Grid>
  );
};

export default Keypad;