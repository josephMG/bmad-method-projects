import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import Home from '../src/app/page';

describe('Home', () => {
  it('renders the main content', () => {
    render(<Home />);
    const mainContent = screen.getByText(/Get started by editing/i);
    expect(mainContent).toBeInTheDocument();
  });
});
