import { render, fireEvent } from '@testing-library/react';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import themeReducer from '@/store/theme/themeSlice';
import SettingsPage from '@/app/dashboard/settings/page';
import ThemeProvider from '@/app/ThemeProvider';

describe('ThemeToggleButton integration', () => {
  it('should toggle theme and apply it to the document', () => {
    const store = configureStore({
      reducer: {
        theme: themeReducer,
      },
    });

    render(
      <Provider store={store}>
        <ThemeProvider>
          <SettingsPage />
        </ThemeProvider>
      </Provider>
    );

    const button = document.querySelector('button');
    expect(button).toBeInTheDocument();

    fireEvent.click(button!);
    expect(store.getState().theme.mode).toBe('dark');
    expect(document.documentElement.classList.contains('dark')).toBe(true);

    fireEvent.click(button!);
    expect(store.getState().theme.mode).toBe('light');
    expect(document.documentElement.classList.contains('dark')).toBe(false);
  });
});
