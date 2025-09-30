
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi, beforeAll, afterEach, afterAll } from 'vitest';
import ProfilePage from '@/app/dashboard/settings/profile/page';
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

// Mock RTK Query hooks
const mockGetUserProfileQuery = vi.fn();
const mockUpdateUserProfileMutation = vi.fn();

vi.mock('@/store/user/userApi', () => ({
  useGetUserProfileQuery: () => mockGetUserProfileQuery(),
  useUpdateUserProfileMutation: () => [
    vi.fn((args) => ({
      unwrap: () => mockUpdateUserProfileMutation(args),
    })),
    { isLoading: false, error: undefined },
  ],
}));

// Mock useAppDispatch to prevent errors related to Redux store setup
vi.mock('@/store/hooks', () => ({
  useAppDispatch: vi.fn(() => vi.fn()),
}));

// Mock setProfile from userSlice
vi.mock('@/store/user/userSlice', () => ({
  setProfile: vi.fn(),
}));

const handlers = [
  http.get(`${process.env.NEXT_PUBLIC_API_BASE_URL}/users/me`, () => {
    return HttpResponse.json({
      id: '123',
      email: 'test@example.com',
      username: 'testuser',
      full_name: 'Test User',
      is_active: true,
      created_at: '2023-01-01T00:00:00Z',
      updated_at: '2023-01-01T00:00:00Z',
    });
  }),
  http.put(`${process.env.NEXT_PUBLIC_API_BASE_URL}/users/me`, async ({ request }) => {
    const data = await request.json();
    return HttpResponse.json({
      id: '123',
      email: data.email || 'test@example.com',
      username: 'testuser',
      full_name: data.full_name || 'Test User',
      is_active: true,
      created_at: '2023-01-01T00:00:00Z',
      updated_at: '2023-01-01T00:00:00Z',
    });
  }),
];

const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => {
  server.resetHandlers();
  vi.clearAllMocks();
});
afterAll(() => server.close());

describe('ProfilePage Integration', () => {
  it('fetches and displays user profile data', async () => {
    mockGetUserProfileQuery.mockReturnValue({
      data: {
        id: '123',
        email: 'test@example.com',
        username: 'testuser',
        full_name: 'Test User',
        is_active: true,
        created_at: '2023-01-01T00:00:00Z',
        updated_at: '2023-01-01T00:00:00Z',
      },
      error: undefined,
      isLoading: false,
    });

    render(<ProfilePage />);

    expect(screen.getByLabelText(/username/i)).toHaveValue('testuser');
    expect(screen.getByLabelText(/email address/i)).toHaveValue('test@example.com');
    expect(screen.getByLabelText(/full name/i)).toHaveValue('Test User');
  });

  it('updates user profile data and displays success message', async () => {
    mockGetUserProfileQuery.mockReturnValue({
      data: {
        id: '123',
        email: 'test@example.com',
        username: 'testuser',
        full_name: 'Test User',
        is_active: true,
        created_at: '2023-01-01T00:00:00Z',
        updated_at: '2023-01-01T00:00:00Z',
      },
      error: undefined,
      isLoading: false,
    });

    mockUpdateUserProfileMutation.mockImplementation((data) => {
      return Promise.resolve({
        data: {
          id: '123',
          email: data.email || 'test@example.com',
          username: 'testuser',
          full_name: data.full_name || 'Test User',
          is_active: true,
          created_at: '2023-01-01T00:00:00Z',
          updated_at: '2023-01-01T00:00:00Z',
        },
      });
    });

    render(<ProfilePage />);

    const user = userEvent.setup();
    const emailInput = screen.getByLabelText(/email address/i);
    const fullNameInput = screen.getByLabelText(/full name/i);
    const updateButton = screen.getByRole('button', { name: /update profile/i });

    await user.clear(emailInput);
    await user.type(emailInput, 'new.email@example.com');
    await user.clear(fullNameInput);
    await user.type(fullNameInput, 'New Name');
    await user.click(updateButton);

    await waitFor(async () => {
      expect(mockUpdateUserProfileMutation).toHaveBeenCalledWith({
        email: 'new.email@example.com',
        full_name: 'New Name',
      });
      expect(await screen.findByText('Profile updated successfully!')).toBeInTheDocument();
    });
  });

  it('displays error message on update failure', async () => {
    mockGetUserProfileQuery.mockReturnValue({
      data: {
        id: '123',
        email: 'test@example.com',
        username: 'testuser',
        full_name: 'Test User',
        is_active: true,
        created_at: '2023-01-01T00:00:00Z',
        updated_at: '2023-01-01T00:00:00Z',
      },
      error: undefined,
      isLoading: false,
    });

    mockUpdateUserProfileMutation.mockImplementation(() => {
      return Promise.reject({
        data: { detail: 'Email already registered' },
        status: 400,
      });
    });

    render(<ProfilePage />);

    const user = userEvent.setup();
    const emailInput = screen.getByLabelText(/email address/i);
    const updateButton = screen.getByRole('button', { name: /update profile/i });

    await user.clear(emailInput);
    await user.type(emailInput, 'existing@example.com');
    await user.click(updateButton);

    await waitFor(async () => {
      expect(await screen.findByText('Email already registered')).toBeInTheDocument();
    });
  });

  it('displays loading spinner when profile data is loading', () => {
    mockGetUserProfileQuery.mockReturnValue({
      data: undefined,
      error: undefined,
      isLoading: true,
    });

    render(<ProfilePage />);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
  });

  it('displays error alert when profile data fails to load', () => {
    mockGetUserProfileQuery.mockReturnValue({
      data: undefined,
      error: { status: 500, data: 'Internal Server Error' },
      isLoading: false,
    });

    render(<ProfilePage />);
    expect(screen.getByText('Failed to load profile. Please try again later.')).toBeInTheDocument();
  });

  it('displays info alert when no user profile data is available', () => {
    mockGetUserProfileQuery.mockReturnValue({
      data: undefined,
      error: undefined,
      isLoading: false,
    });

    render(<ProfilePage />);
    expect(screen.getByText('No user profile data available.')).toBeInTheDocument();
  });
});
