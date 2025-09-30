import { render, fireEvent } from '@testing-library/react';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import themeReducer from '@/store/theme/themeSlice';
import ThemeToggleButton from '@/components/common/ThemeToggleButton/ThemeToggleButton';

describe('ThemeToggleButton', () => {
  it('should render and toggle theme', () => {
    const store = configureStore({
      reducer: {
        theme: themeReducer,
      },
    });

    const { getByRole } = render(
      <Provider store={store}>
        <ThemeToggleButton />
      </Provider>
    );

    const button = getByRole('button');
    expect(button).toBeInTheDocument();

    fireEvent.click(button);
    expect(store.getState().theme.mode).toBe('dark');

    fireEvent.click(button);
    expect(store.getState().theme.mode).toBe('light');
  });
});
