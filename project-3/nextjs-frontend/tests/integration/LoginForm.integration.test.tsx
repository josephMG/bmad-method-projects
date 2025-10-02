import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import LoginForm from '@/components/auth/LoginForm';
import { describe, it, expect, vi } from 'vitest';
import { useRouter } from 'next/navigation';
import { http, HttpResponse } from 'msw';
import { server } from '../server';
import { ReduxProvider } from '@/store/provider';

// Mock useRouter
vi.mock('next/navigation', () => ({
  useRouter: vi.fn(() => ({
    push: vi.fn(),
  })),
}));

let mockLoginMutationState = {
  isLoading: false,
  isSuccess: false,
  isError: false,
  error: null,
};

const mockLogin = vi.fn(() => {
  if (mockLoginMutationState.isSuccess) {
    return Promise.resolve({ data: { access_token: 'mock_jwt_token', token_type: 'bearer' } });
  } else if (mockLoginMutationState.isError) {
    // Mimic RTK Query's error structure
    return Promise.reject({
      status: mockLoginMutationState.error?.status || 500,
      data: mockLoginMutationState.error?.data || { detail: 'An unexpected error occurred.' },
    });
  }
  return Promise.resolve({});
});

vi.mock('@/redux/features/auth/authSlice', () => ({
  useLoginMutation: vi.fn(() => [mockLogin, mockLoginMutationState]),
}));

describe('LoginForm Integration', () => {
  beforeEach(() => {
    // Reset the mock state before each test
    mockLoginMutationState = {
      isLoading: false,
      isSuccess: false,
      isError: false,
      error: null,
    };
    mockLogin.mockClear();
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  // AC: Successful Login & JWT Handling
  it('successfully logs in and redirects to dashboard', async () => {
    mockLoginMutationState.isSuccess = true;
    server.use(
      http.post('http://localhost:8000/api/v1/token', () => {
        return HttpResponse.json({ access_token: 'mock_jwt_token', token_type: 'bearer' })
      })
    )
    const mockPush = vi.fn();
    (useRouter as vi.Mock).mockReturnValue({ push: mockPush });

    render(<ReduxProvider><LoginForm /></ReduxProvider>);

    await userEvent.type(screen.getByRole('textbox', { name: /username/i }), 'testuser');
    await userEvent.type(screen.getByTestId('password-input'), 'Password123!');

    fireEvent.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(screen.getByText(/login successful/i)).toBeInTheDocument();
    });

    await waitFor(() => {
      expect(mockPush).toHaveBeenCalledWith('/dashboard');
    }, { timeout: 3000 });
  });

  // AC: Error Handling
  it('displays error message on invalid credentials', async () => {
    mockLoginMutationState.isError = true;
    mockLoginMutationState.error = { status: 401, data: { detail: 'Invalid credentials' } };
    server.use(
      http.post('http://localhost:8000/api/v1/token', () => {
        return new HttpResponse(JSON.stringify({ detail: 'Invalid credentials' }), { status: 401 });
      })
    );

    render(<ReduxProvider><LoginForm /></ReduxProvider>);

    await userEvent.type(screen.getByRole('textbox', { name: /username/i }), 'testuser');
    await userEvent.type(screen.getByTestId('password-input'), 'wrongpassword');

    fireEvent.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(screen.getByText(/invalid credentials/i)).toBeInTheDocument();
    });
  });

  // AC: Error Handling
  it('displays generic error message on server error', async () => {
    mockLoginMutationState.isError = true;
    mockLoginMutationState.error = { status: 500, data: { detail: 'Internal Server Error' } }; // Mock a generic error message
    server.use(
      http.post('http://localhost:8000/api/v1/token', () => {
        return new HttpResponse(null, { status: 500 });
      })
    );

    render(<ReduxProvider><LoginForm /></ReduxProvider>);

    await userEvent.type(screen.getByRole('textbox', { name: /username/i }), 'testuser');
    await userEvent.type(screen.getByTestId('password-input'), 'Password123!');

    fireEvent.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(screen.getByText(/an unexpected error occurred/i)).toBeInTheDocument();
    });
  });
});