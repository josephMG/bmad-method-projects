import React from 'react';
import { Box, Typography, List, ListItem, ListItemText } from '@mui/material';

interface HistoryProps {
  history: string[];
  onHistoryClick: (value: string) => void;
}

const History: React.FC<HistoryProps> = ({ history, onHistoryClick }) => {
  const extractResult = (equation: string): string => {
    const parts = equation.split('=');
    if (parts.length > 1) {
      return parts[1].trim();
    }
    return equation; // Fallback if '=' not found
  };

  return (
    <Box
      sx={{
        backgroundColor: '#f0f0f0',
        padding: 1,
        borderRadius: 1,
        minHeight: 150,
        maxHeight: 250, // Limit height for scrolling
        overflowY: 'auto', // Enable scrolling
        display: 'flex',
        flexDirection: 'column-reverse', // Display newest at bottom, but scroll from top
        border: '1px solid #e0e0e0',
      }}
    >
      {history.length === 0 ? (
        <Typography variant="body2" color="textSecondary" sx={{ textAlign: 'center', mt: 2 }}>
          No history yet
        </Typography>
      ) : (
        <List dense>
          {history.map((item, index) => (
            <ListItem
              key={index}
              button // Makes the ListItem clickable
              onClick={() => onHistoryClick(extractResult(item))}
              sx={{ justifyContent: 'flex-end' }}
            >
              <ListItemText primary={item} sx={{ textAlign: 'right' }} />
            </ListItem>
          ))}
        </List>
      )}
    </Box>
  );
};

export default History;