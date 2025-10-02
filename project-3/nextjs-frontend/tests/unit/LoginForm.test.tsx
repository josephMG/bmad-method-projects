import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import LoginForm from "@/components/auth/LoginForm";
import { describe, it, expect, vi } from "vitest";
import { useRouter } from "next/navigation";
import { http, HttpResponse } from "msw";
import { server } from "../server";
import { ReduxProvider } from "@/store/provider";

// Mock useRouter
vi.mock("next/navigation", () => ({
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
    return Promise.resolve({
      data: { access_token: "mock_jwt_token", token_type: "bearer" },
    });
  } else if (mockLoginMutationState.isError) {
    // Mimic RTK Query's error structure
    return Promise.reject({
      status: mockLoginMutationState.error?.status || 500,
      data: mockLoginMutationState.error?.data || {
        detail: "An unexpected error occurred.",
      },
    });
  }
  return Promise.resolve({});
});

vi.mock("@/redux/features/auth/authSlice", () => ({
  useLoginMutation: vi.fn(() => [mockLogin, mockLoginMutationState]),
}));

describe("LoginForm", () => {
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

  // AC: Login Form Display
  it("renders all form fields correctly", () => {
    render(
      <ReduxProvider>
        <LoginForm />
      </ReduxProvider>,
    );

    expect(
      screen.getByRole("textbox", { name: /username/i }),
    ).toBeInTheDocument();
    expect(screen.getByTestId("password-input")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /login/i })).toBeInTheDocument();
  });

  // AC: Input Validation
  it("displays validation errors for empty fields on submit", async () => {
    render(
      <ReduxProvider>
        <LoginForm />
      </ReduxProvider>,
    );
    const loginButton = screen.getByRole("button", { name: /login/i });

    fireEvent.click(loginButton);

    await waitFor(() => {
      expect(screen.getByText(/username is required/i)).toBeInTheDocument();
      expect(screen.getByText(/password is required/i)).toBeInTheDocument();
    });
  });

  // AC: Successful Login & JWT Handling
  it("calls API and redirects on successful login", async () => {
    mockLoginMutationState.isSuccess = true;
    server.use(
      http.post("http://localhost:8000/api/v1/token", () => {
        return HttpResponse.json({
          access_token: "mock_jwt_token",
          token_type: "bearer",
        });
      }),
    );
    const mockPush = vi.fn();
    (useRouter as vi.Mock).mockReturnValue({ push: mockPush });

    render(
      <ReduxProvider>
        <LoginForm />
      </ReduxProvider>,
    );

    await userEvent.type(
      screen.getByRole("textbox", { name: /username/i }),
      "testuser",
    );
    await userEvent.type(screen.getByTestId("password-input"), "Password123!");

    fireEvent.click(screen.getByRole("button", { name: /login/i }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(/login successful/i);
    });

    await waitFor(
      () => {
        expect(mockPush).toHaveBeenCalledWith("/dashboard");
      },
      { timeout: 3000 },
    ); // Wait for the setTimeout to complete
  });

  // AC: Error Handling
  it("displays error message on API login failure", async () => {
    mockLoginMutationState.isError = true;
    mockLoginMutationState.error = {
      status: 401,
      data: { detail: "Invalid credentials" },
    };
    server.use(
      http.post("http://localhost:8000/api/v1/token", () => {
        return new HttpResponse(
          JSON.stringify({ detail: "Invalid credentials" }),
          { status: 401 },
        );
      }),
    );

    render(
      <ReduxProvider>
        <LoginForm />
      </ReduxProvider>,
    );

    await userEvent.type(
      screen.getByRole("textbox", { name: /username/i }),
      "testuser",
    );
    await userEvent.type(screen.getByTestId("password-input"), "wrongpassword");

    fireEvent.click(screen.getByRole("button", { name: /login/i }));

    await waitFor(() => {
      const alertElement = screen.getByRole("alert");
      expect(alertElement.textContent).toMatch(/invalid credentials/i);
    });
  });

  // AC: Security - JWT Handling
  it("handles JWT securely on successful login (e.g., via HTTP-only cookie)", async () => {
    mockLoginMutationState.isSuccess = true;
    server.use(
      http.post("http://localhost:8000/api/v1/token", () => {
        // Simulate setting an HTTP-only cookie with the JWT
        return HttpResponse.json(
          { access_token: "mock_jwt_token", token_type: "bearer" },
          {
            headers: {
              "Set-Cookie":
                "access_token=mock_jwt_token; HttpOnly; Path=/; Max-Age=3600",
            },
          },
        );
      }),
    );
    const mockPush = vi.fn();
    (useRouter as vi.Mock).mockReturnValue({ push: mockPush });

    render(
      <ReduxProvider>
        <LoginForm />
      </ReduxProvider>,
    );

    await userEvent.type(
      screen.getByRole("textbox", { name: /username/i }),
      "testuser",
    );
    await userEvent.type(screen.getByTestId("password-input"), "Password123!");

    fireEvent.click(screen.getByRole("button", { name: /login/i }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(/login successful/i);
    });

    await waitFor(
      () => {
        expect(mockPush).toHaveBeenCalledWith("/dashboard");
      },
      { timeout: 3000 },
    );

    // Assert that the JWT is NOT directly accessible in the client-side DOM or local storage
    expect(document.cookie).not.toContain("access_token=mock_jwt_token");
    expect(localStorage.getItem("access_token")).toBeNull();
  });

  // AC: Security - XSS Prevention
  it("prevents XSS attacks by sanitizing user input", async () => {
    render(
      <ReduxProvider>
        <LoginForm />
      </ReduxProvider>,
    );
    const usernameInput = screen.getByRole("textbox", { name: /username/i });
    const passwordInput = screen.getByTestId("password-input");
    const loginButton = screen.getByRole("button", { name: /login/i });

    const maliciousInput = '<script>alert("XSS")</script>';

    await userEvent.type(usernameInput, maliciousInput);
    await userEvent.type(passwordInput, "Password123!");

    fireEvent.click(loginButton);

    // Expect the malicious input not to be present in the rendered DOM as executable script
    expect(
      screen.queryByText(/<script>alert("XSS")<\/script>/i),
    ).not.toBeInTheDocument();
    expect(screen.queryByText(/alert("XSS")/i)).not.toBeInTheDocument();
  });

  // AC: Accessibility - Keyboard Navigation & ARIA Attributes
  it("supports keyboard navigation through form fields and has correct ARIA attributes", async () => {
    const user = userEvent.setup();
    render(
      <ReduxProvider>
        <LoginForm />
      </ReduxProvider>,
    );

    const usernameInput = screen.getByRole("textbox", { name: /username/i });
    const passwordInput = screen.getByTestId("password-input");
    const loginButton = screen.getByRole("button", { name: /login/i });

    // Check for ARIA attributes
    expect(usernameInput).toHaveAccessibleName(/username/i);
    expect(passwordInput).toHaveAccessibleName(/password/i);

    // Start tabbing from the beginning of the document
    await user.tab();
    expect(usernameInput).toHaveFocus();

    // Tab to password input
    await user.tab();
    expect(passwordInput).toHaveFocus();

    // Tab to login button
    await user.tab();
    expect(loginButton).toHaveFocus();
  });
});

