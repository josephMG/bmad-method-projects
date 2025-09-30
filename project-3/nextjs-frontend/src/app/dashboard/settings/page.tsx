// nextjs-frontend/src/app/dashboard/settings/page.tsx
'use client';

import React from 'react';
import { Typography, Box, Container } from '@mui/material';
import { ThemeToggleButton } from '@/components/common/ThemeToggleButton';

const SettingsPage: React.FC = () => {
  return (
    <Container maxWidth="md">
      <Box sx={{ my: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          Settings
        </Typography>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
          <Typography variant="h6">Dark Mode</Typography>
          <ThemeToggleButton />
        </Box>
        {/* Other settings can go here */}
      </Box>
    </Container>
  );
};

export default SettingsPage;
