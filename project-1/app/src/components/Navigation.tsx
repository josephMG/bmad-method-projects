
import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Tabs, Tab, Box } from '@mui/material';

const Navigation: React.FC = () => {
  const location = useLocation();

  return (
    <Box sx={{ borderBottom: 1, borderColor: 'divider', width: '100%', backgroundColor: '#fff' }}>
      <Tabs value={location.pathname} centered>
        <Tab label="Basic Calculator" value="/" to="/" component={Link} />
        <Tab label="Scientific Calculator" value="/scientific" to="/scientific" component={Link} />
        <Tab label="Currency Exchange" value="/currency" to="/currency" component={Link} />
      </Tabs>
    </Box>
  );
};

export default Navigation;
