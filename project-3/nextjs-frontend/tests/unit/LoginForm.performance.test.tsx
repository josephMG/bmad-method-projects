import { render } from "@testing-library/react";
import LoginForm from "@/components/auth/LoginForm";
import { describe, it, expect, vi } from "vitest";
import { ReduxProvider } from "@/store/provider";

// Mock useRouter and useLoginMutation to isolate component rendering
vi.mock("next/navigation", () => ({
  useRouter: vi.fn(() => ({
    push: vi.fn(),
  })),
}));

vi.mock("@/redux/features/auth/authSlice", () => ({
  useLoginMutation: vi.fn(() => [
    vi.fn(),
    { isLoading: false, isSuccess: false, isError: false, error: null },
  ]),
}));

describe("LoginForm Performance", () => {
  // AC: Performance - Render Time
  it("renders quickly without significant performance overhead", () => {
    const startTime = performance.now();
    render(
      <ReduxProvider>
        <LoginForm />
      </ReduxProvider>,
    );
    const endTime = performance.now();
    const renderTime = endTime - startTime;

    // Assert that the render time is below a certain threshold (e.g., 50ms)
    // This threshold might need adjustment based on the test environment and component complexity.
    expect(renderTime).toBeLessThan(250);
  });
});

