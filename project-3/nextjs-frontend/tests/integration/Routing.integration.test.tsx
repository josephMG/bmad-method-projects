import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { useRouter } from 'next/navigation';
import { http, HttpResponse } from 'msw';
import { server } from '../server';
import { ReduxProvider } from '@/store/provider';

// Pages to test
import LoginPage from '@/app/login/page';
import RegisterPage from '@/app/register/page';
import DashboardPage from '@/app/dashboard/page';

// Mock useRouter
const mockPush = vi.fn();
vi.mock('next/navigation', () => ({
  useRouter: vi.fn(() => ({
    push: mockPush,
  })),
}));

vi.mock('next/link', () => ({
  __esModule: true,
  default: vi.fn(({ children, href }) => {
    return (
      <a href={href} onClick={(e) => {
        e.preventDefault();
        mockPush(href);
      }}>
        {children}
      </a>
    );
  }),
}));

describe('Frontend Routing and Navigation', () => {
  beforeEach(() => {
    server.resetHandlers();
    mockPush.mockClear();
  });

  // AC: 1 - Navigation between Login and Register pages
  it('allows navigation between Login and Register pages', async () => {
    render(<ReduxProvider><LoginPage /></ReduxProvider>);

    // Go to Register from Login
    fireEvent.click(screen.getByRole('link', { name: /sign up/i }));
    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/register');
    });
    mockPush.mockClear();

    render(<ReduxProvider><RegisterPage /></ReduxProvider>);

    // Go to Login from Register
    fireEvent.click(screen.getByRole('link', { name: /login/i }));
    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/login');
    });
  });

  // AC: 2 - Successful login redirects to Dashboard
  it('redirects to dashboard upon successful login', async () => {
    server.use(
      http.post('http://localhost:8000/api/v1/token', () => {
        return HttpResponse.json({ access_token: 'mock_jwt_token', token_type: 'bearer' });
      })
    );

    render(<ReduxProvider><LoginPage /></ReduxProvider>);

    await userEvent.type(screen.getByRole('textbox', { name: /username/i }), 'testuser');
    await userEvent.type(screen.getByTestId('password-input'), 'Password123!');
    fireEvent.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/dashboard');
    }, { timeout: 3000 }); // Increased timeout for async operations
  });

  // AC: 3 - Navigation from Dashboard to other pages
  it('allows navigation from Dashboard to profile, change password, and delete account pages', async () => {
    render(<ReduxProvider><DashboardPage /></ReduxProvider>);

    // Go to Profile
    fireEvent.click(screen.getByRole('link', { name: /profile/i }));
    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/dashboard/settings/profile');
    });
    mockPush.mockClear();

    // Go to Change Password
    fireEvent.click(screen.getByRole('link', { name: /change password/i }));
    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/dashboard/settings/change-password');
    });
    mockPush.mockClear();

    // Go to Delete Account
    fireEvent.click(screen.getByRole('link', { name: /delete account/i }));
    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/dashboard/settings/delete-account');
    });
  });
});
