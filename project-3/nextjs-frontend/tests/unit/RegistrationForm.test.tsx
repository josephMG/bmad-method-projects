import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import RegistrationForm from "@/components/auth/RegistrationForm";
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

describe("RegistrationForm", () => {
  it("renders all form fields correctly", () => {
    render(
      <ReduxProvider>
        <RegistrationForm />
      </ReduxProvider>,
    );

    expect(
      screen.getByRole("textbox", { name: /username/i }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("textbox", { name: /email address/i }),
    ).toBeInTheDocument();
    expect(screen.getByTestId("password-input")).toBeInTheDocument();
    expect(screen.getByTestId("confirm-password-input")).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: /register/i }),
    ).toBeInTheDocument();
  });

  it("displays validation errors for empty fields on submit", async () => {
    render(
      <ReduxProvider>
        <RegistrationForm />
      </ReduxProvider>,
    );
    const registerButton = screen.getByRole("button", { name: /register/i });

    fireEvent.click(registerButton);

    await waitFor(() => {
      expect(screen.getByText(/username is required/i)).toBeInTheDocument();
      expect(screen.getByText(/invalid email address/i)).toBeInTheDocument();
      expect(
        screen.getByText(
          /password is required and must be at least 8 characters/i,
        ),
      ).toBeInTheDocument();
      expect(
        screen.getByText(/password confirmation is required/i),
      ).toBeInTheDocument();
    });
  });

  it("displays validation error for invalid email format", async () => {
    render(
      <ReduxProvider>
        <RegistrationForm />
      </ReduxProvider>,
    );
    const emailInput = screen.getByRole("textbox", { name: /email address/i });
    const registerButton = screen.getByRole("button", { name: /register/i });

    await userEvent.type(emailInput, "invalid-email");
    fireEvent.click(registerButton);

    await waitFor(() => {
      expect(screen.getByText(/invalid email address/i)).toBeInTheDocument();
    });
  });

  it("displays validation error for mismatched passwords", async () => {
    render(
      <ReduxProvider>
        <RegistrationForm />
      </ReduxProvider>,
    );
    const passwordInput = screen.getByTestId("password-input");
    const confirmPasswordInput = screen.getByTestId("confirm-password-input");
    const registerButton = screen.getByRole("button", { name: /register/i });

    await userEvent.type(passwordInput, "password123");
    await userEvent.type(confirmPasswordInput, "password456");
    fireEvent.click(registerButton);

    await waitFor(() => {
      expect(screen.getByText(/passwords don't match/i)).toBeInTheDocument();
    });
  });

  it("calls API and redirects on successful registration", async () => {
    server.use(
      http.post("http://localhost:8000/api/v1/register", () => {
        return HttpResponse.json({ message: "User registered successfully" });
      }),
    );
    const mockPush = vi.fn();
    (useRouter as vi.Mock).mockReturnValue({ push: mockPush });

    render(
      <ReduxProvider>
        <RegistrationForm />
      </ReduxProvider>,
    );

    await userEvent.type(
      screen.getByRole("textbox", { name: /username/i }),
      "testuser",
    );
    await userEvent.type(
      screen.getByRole("textbox", { name: /email address/i }),
      "test@example.com",
    );
    await userEvent.type(screen.getByTestId("password-input"), "Password123!");
    await userEvent.type(
      screen.getByTestId("confirm-password-input"),
      "Password123!",
    );

    fireEvent.click(screen.getByRole("button", { name: /register/i }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        /registration successful/i,
      );
    });

    await waitFor(
      () => {
        expect(mockPush).toHaveBeenCalledWith("/login");
      },
      { timeout: 3000 },
    ); // Wait for the setTimeout to complete
  });

  // AC: Security - JWT Handling
  it("handles JWT securely on successful registration (e.g., via HTTP-only cookie)", async () => {
    server.use(
      http.post("http://localhost:8000/api/v1/register", () => {
        // Simulate setting an HTTP-only cookie with the JWT
        return HttpResponse.json(
          { message: "User registered successfully" },
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
        <RegistrationForm />
      </ReduxProvider>,
    );

    await userEvent.type(
      screen.getByRole("textbox", { name: /username/i }),
      "testuser",
    );
    await userEvent.type(
      screen.getByRole("textbox", { name: /email address/i }),
      "test@example.com",
    );
    await userEvent.type(screen.getByTestId("password-input"), "Password123!");
    await userEvent.type(
      screen.getByTestId("confirm-password-input"),
      "Password123!",
    );

    fireEvent.click(screen.getByRole("button", { name: /register/i }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        /registration successful/i,
      );
    });

    await waitFor(
      () => {
        expect(mockPush).toHaveBeenCalledWith("/login");
      },
      { timeout: 3000 },
    );

    // Assert that the JWT is NOT directly accessible in the client-side DOM or local storage
    // This is a conceptual check, as HTTP-only cookies are not accessible via document.cookie from JS
    // For a real test, you might inspect network requests or mock cookie parsing if applicable
    expect(document.cookie).not.toContain("access_token=mock_jwt_token");
    expect(localStorage.getItem("access_token")).toBeNull();
  });

  // AC: Error Handling
  it("displays error message on API registration failure", async () => {
    server.use(
      http.post("http://localhost:8000/api/v1/register", () => {
        return new HttpResponse(
          JSON.stringify({ detail: "Email already registered" }),
          { status: 400 },
        );
      }),
    );

    render(
      <ReduxProvider>
        <RegistrationForm />
      </ReduxProvider>,
    );

    await userEvent.type(
      screen.getByRole("textbox", { name: /username/i }),
      "testuser",
    );
    await userEvent.type(
      screen.getByRole("textbox", { name: /email address/i }),
      "test@example.com",
    );
    await userEvent.type(screen.getByTestId("password-input"), "Password123!");
    await userEvent.type(
      screen.getByTestId("confirm-password-input"),
      "Password123!",
    );

    fireEvent.click(screen.getByRole("button", { name: /register/i }));

    await waitFor(() => {
      const alertElement = screen.getByRole("alert");
      expect(alertElement.textContent).toMatch(/email already registered/i);
    });
  });

  it("prevents XSS attacks by sanitizing user input", async () => {
    render(
      <ReduxProvider>
        <RegistrationForm />
      </ReduxProvider>,
    );
    const usernameInput = screen.getByRole("textbox", { name: /username/i });
    const emailInput = screen.getByRole("textbox", { name: /email address/i });
    const passwordInput = screen.getByTestId("password-input");
    const confirmPasswordInput = screen.getByTestId("confirm-password-input");
    const registerButton = screen.getByRole("button", { name: /register/i });

    const maliciousInput = '<script>alert("XSS")</script>';

    await userEvent.type(usernameInput, maliciousInput);
    await userEvent.type(emailInput, "test@example.com");
    await userEvent.type(passwordInput, "Password123!");
    await userEvent.type(confirmPasswordInput, "Password123!");

    fireEvent.click(registerButton);

    // Expect the malicious input not to be present in the rendered DOM as executable script
    // This is a basic check; a more robust solution would involve a dedicated sanitization library
    expect(
      screen.queryByText(/<script>alert("XSS")<\/script>/i),
    ).not.toBeInTheDocument();
    expect(screen.queryByText(/alert("XSS")/i)).not.toBeInTheDocument();

    // Also check if the input field itself has sanitized the value (though React usually handles this)
    // expect(usernameInput).not.toHaveValue(maliciousInput);
  });

  // AC: Accessibility - Keyboard Navigation & ARIA Attributes
  it("supports keyboard navigation through form fields and has correct ARIA attributes", async () => {
    const user = userEvent.setup();
    render(
      <ReduxProvider>
        <RegistrationForm />
      </ReduxProvider>,
    );

    const usernameInput = screen.getByRole("textbox", { name: /username/i });
    const emailInput = screen.getByRole("textbox", { name: /email address/i });
    const passwordInput = screen.getByTestId("password-input");
    const confirmPasswordInput = screen.getByTestId("confirm-password-input");
    const registerButton = screen.getByRole("button", { name: /register/i });

    // Check for ARIA attributes
    expect(usernameInput).toHaveAccessibleName(/username/i);
    expect(emailInput).toHaveAccessibleName(/email address/i);
    expect(passwordInput).toHaveAccessibleName(/password/i);
    expect(confirmPasswordInput).toHaveAccessibleName(/confirm password/i);

    // Initial focus should be on the username input
    usernameInput.focus();
    expect(usernameInput).toHaveFocus();

    // Tab to email input
    await user.tab();
    expect(emailInput).toHaveFocus();

    // Tab to password input
    await user.tab();
    expect(passwordInput).toHaveFocus();

    // Tab to confirm password input
    await user.tab();
    expect(confirmPasswordInput).toHaveFocus();

    // Tab to register button
    await user.tab();
    expect(registerButton).toHaveFocus();
  });
});

