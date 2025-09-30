

import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi, beforeAll, afterEach, afterAll } from 'vitest';
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';
import { logout } from '@/store/auth/authSlice';

// Mock RTK Query hooks
const mockChangePasswordMutation = vi.fn();

vi.mock('@/store/user/userApi', () => ({
  useChangePasswordMutation: () => [
    vi.fn((args) => ({
      unwrap: () => mockChangePasswordMutation(args),
    })),
    { isLoading: false, error: undefined },
  ],
}));

vi.mock('@/store/auth/authSlice', async (importOriginal) => {
  const actual = await importOriginal() as object;
  return {
    ...actual,
    logout: vi.fn(),
  };
});

// Mock useRouter
const mockPush = vi.fn();
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: mockPush,
  }),
}));

// Now import the component under test after all mocks are defined
import ChangePasswordPage from '@/app/dashboard/settings/change-password/page';

const handlers = [
  http.put(`${process.env.NEXT_PUBLIC_API_BASE_URL}/users/me/password`, async ({ request }) => {
    const data = await request.json();
    if (data.current_password === 'wrong_password') {
      return HttpResponse.json({ detail: 'Incorrect current password' }, { status: 400 });
    }
    return HttpResponse.json({}, { status: 200 });
  }),
];

const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => {
  server.resetHandlers();
  vi.clearAllMocks();
});
afterAll(() => server.close());

describe('ChangePasswordPage Integration', () => {
  it('successfully changes password and redirects to login', async () => {
    mockChangePasswordMutation.mockImplementation(() => Promise.resolve({}));

    render(<ChangePasswordPage />);

    const user = userEvent.setup();
    const currentPasswordInput = screen.getByLabelText(/current password/i);
    const newPasswordInput = screen.getByLabelText(/^new password$/i);
    const confirmNewPasswordInput = screen.getByLabelText(/confirm new password/i);
    const changePasswordButton = screen.getByRole('button', { name: /change password/i });

    await user.type(currentPasswordInput, 'CurrentPassword123!');
    await user.type(newPasswordInput, 'NewPassword456!');
    await user.type(confirmNewPasswordInput, 'NewPassword456!');
    await user.click(changePasswordButton);

    await waitFor(async () => {
      expect(mockChangePasswordMutation).toHaveBeenCalledWith({
        current_password: 'CurrentPassword123!',
        new_password: 'NewPassword456!',
      });
      expect(await screen.findByText('Password changed successfully! Please log in again.')).toBeInTheDocument();
      expect(logout).toHaveBeenCalledTimes(1);
      expect(mockPush).toHaveBeenCalledWith('/login');
    }, { timeout: 5000 });
  });

  it('displays error message on password change failure', async () => {
    mockChangePasswordMutation.mockImplementation(() =>
      Promise.reject({
        data: { detail: 'Incorrect current password' },
        status: 400,
      })
    );

    render(<ChangePasswordPage />);

    const user = userEvent.setup();
    const currentPasswordInput = screen.getByLabelText(/current password/i);
    const newPasswordInput = screen.getByLabelText(/^new password$/i);
    const confirmNewPasswordInput = screen.getByLabelText(/confirm new password/i);
    const changePasswordButton = screen.getByRole('button', { name: /change password/i });

    await user.type(currentPasswordInput, 'wrong_password');
    await user.type(newPasswordInput, 'NewPassword456!');
    await user.type(confirmNewPasswordInput, 'NewPassword456!');
    await user.click(changePasswordButton);

    await waitFor(async () => {
      expect(await screen.findByText('Incorrect current password')).toBeInTheDocument();
      expect(logout).not.toHaveBeenCalled();
      expect(mockPush).not.toHaveBeenCalled();
    }, { timeout: 5000 });
  });
});
