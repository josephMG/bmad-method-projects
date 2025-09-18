
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import CalculatorPage from './pages/CalculatorPage';
import ScientificCalculatorPage from './pages/ScientificCalculatorPage';
import CurrencyExchangePage from './pages/CurrencyExchangePage';
import Navigation from './components/Navigation';
import { Box } from '@mui/material';

const App: React.FC = () => {
  return (
    <Router>
      <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
        <Navigation />
        <Box sx={{ flexGrow: 1 }}>
          <Routes>
            <Route path="/" element={<CalculatorPage />} />
            <Route path="/scientific" element={<ScientificCalculatorPage />} />
            <Route path="/currency" element={<CurrencyExchangePage />} />
          </Routes>
        </Box>
      </Box>
    </Router>
  );
};

export default App;
