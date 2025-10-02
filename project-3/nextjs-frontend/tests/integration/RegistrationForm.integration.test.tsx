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

describe("RegistrationForm Integration", () => {
  it("successfully registers a user and redirects", async () => {
    server.use(
      http.post("http://localhost:8000/api/v1/register", () => {
        return HttpResponse.json({
          id: "a1b2c3d4-e5f6-7890-1234-567890abcdef",
          email: "integration@example.com",
          username: "integrationuser",
          full_name: null,
          is_active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        });
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
      "integrationuser",
    );
    await userEvent.type(
      screen.getByRole("textbox", { name: /email address/i }),
      "integration@example.com",
    );
    await userEvent.type(
      screen.getByTestId("password-input"),
      "Integration123!",
    );
    await userEvent.type(
      screen.getByTestId("confirm-password-input"),
      "Integration123!",
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
  });

  it("displays API error message on registration failure", async () => {
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
      "failuser",
    );
    await userEvent.type(
      screen.getByRole("textbox", { name: /email address/i }),
      "fail@example.com",
    );
    await userEvent.type(screen.getByTestId("password-input"), "Fail123!");
    await userEvent.type(
      screen.getByTestId("confirm-password-input"),
      "Fail123!",
    );

    fireEvent.click(screen.getByRole("button", { name: /register/i }));

    await waitFor(() => {
      const alertElement = screen.getByRole("alert");
      expect(alertElement.textContent).toMatch(
        /email already registered/i,
      );
    });
  });
});
