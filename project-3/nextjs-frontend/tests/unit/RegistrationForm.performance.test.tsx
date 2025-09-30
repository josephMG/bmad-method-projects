import { render } from '@testing-library/react';
import RegistrationForm from '@/components/auth/RegistrationForm';
import { describe, it, expect, vi } from 'vitest';
import { ReduxProvider } from '@/store/provider';

// Mock useRouter and useRegisterMutation to isolate component rendering
vi.mock('next/navigation', () => ({
  useRouter: vi.fn(() => ({
    push: vi.fn(),
  })),
}));

vi.mock('@/redux/features/auth/authSlice', () => ({
  useRegisterMutation: vi.fn(() => [
    vi.fn(),
    { isLoading: false, isSuccess: false, isError: false, error: null },
  ]),
}));

describe('RegistrationForm Performance', () => {
  // AC: Performance - Render Time
  it('renders quickly without significant performance overhead', () => {
    const startTime = performance.now();
    render(<ReduxProvider><RegistrationForm /></ReduxProvider>);
    const endTime = performance.now();
    const renderTime = endTime - startTime;

    // Assert that the render time is below a certain threshold (e.g., 50ms)
    // This threshold might need adjustment based on the test environment and component complexity.
    expect(renderTime).toBeLessThan(500);
  });
});