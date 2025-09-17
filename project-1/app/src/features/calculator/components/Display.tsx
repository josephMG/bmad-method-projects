import React from 'react';
import { Box, Typography } from '@mui/material';

interface DisplayProps {
  value: string;
}

const Display: React.FC<DisplayProps> = ({ value }) => {
  return (
    <Box
      sx={{
        backgroundColor: '#424242',
        color: '#ffffff',
        padding: 2,
        borderRadius: 1,
        textAlign: 'right',
        fontSize: '2.5rem',
        fontWeight: 'bold',
        overflow: 'hidden',
        whiteSpace: 'nowrap',
        mb: 2, // Margin bottom
      }}
    >
      <Typography variant="h3" component="div" sx={{ color: 'inherit' }}>
        {value || '0'}
      </Typography>
    </Box>
  );
};

export default Display;
