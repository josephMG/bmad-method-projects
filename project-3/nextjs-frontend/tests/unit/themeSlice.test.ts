import themeReducer, { setTheme, toggleTheme } from '@/store/theme/themeSlice';

describe('themeSlice', () => {
  it('should return the initial state', () => {
    expect(themeReducer(undefined, { type: '' })).toEqual({
      mode: 'light',
    });
  });

  it('should handle setTheme', () => {
    expect(themeReducer(undefined, setTheme('dark'))).toEqual({
      mode: 'dark',
    });
  });

  it('should handle toggleTheme', () => {
    expect(themeReducer({ mode: 'light' }, toggleTheme())).toEqual({
      mode: 'dark',
    });
  });
});
