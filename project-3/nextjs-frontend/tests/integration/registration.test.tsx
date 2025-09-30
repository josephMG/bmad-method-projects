import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";
import { server } from "../server";
import RegistrationForm from "@/components/auth/RegistrationForm";
import { useRouter } from "next/navigation";
import { ReduxProvider } from "@/store/provider";
import {
  afterAll,
  afterEach,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from "vitest";

// Mock the useRouter hook
vi.mock("next/navigation", () => ({
  useRouter: vi.fn(),
}));

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

const renderWithProviders = (component: React.ReactElement) => {
  return render(<ReduxProvider>{component}</ReduxProvider>);
};

describe("RegistrationForm Integration Tests", () => {
  const mockPush = vi.fn();

  beforeEach(() => {
    (useRouter as vi.Mock).mockReturnValue({
      push: mockPush,
    });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it("should successfully register a user and redirect to login", async () => {
    server.use(
      http.post("http://localhost:8000/api/v1/register", () => {
        return HttpResponse.json(
          {
            message: "Registration successful! Redirecting to login...",
            id: "123",
            username: "testuser",
            email: "test@example.com",
            is_active: true,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          },
          { status: 201 },
        );
      }),
    );

    renderWithProviders(<RegistrationForm />);
    const user = userEvent.setup();

    await user.type(
      screen.getByRole("textbox", { name: /username/i }),
      "testuser",
    );
    await user.type(
      screen.getByRole("textbox", { name: /email address/i }),
      "test@example.com",
    );
    await user.type(screen.getByTestId("password-input"), "SecurePassword123");
    await user.type(
      screen.getByTestId("confirm-password-input"),
      "SecurePassword123",
    );

    await user.click(screen.getByRole("button", { name: /register/i }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        /registration successful! redirecting to login.../i,
      );
    });

    await waitFor(
      () => {
        expect(mockPush).toHaveBeenCalledWith("/login");
      },
      { timeout: 3000 },
    ); // Increased timeout due to setTimeout in component
  });

  it("should display an error message if email already exists", async () => {
    server.use(
      http.post("http://localhost:8000/api/v1/register", () => {
        return HttpResponse.json(
          { detail: "Email already registered" },
          { status: 400 },
        );
      }),
    );

    renderWithProviders(<RegistrationForm />);
    const user = userEvent.setup();

    await user.type(
      screen.getByRole("textbox", { name: /username/i }),
      "testuser",
    );
    await user.type(
      screen.getByRole("textbox", { name: /email address/i }),
      "existing@example.com",
    );
    await user.type(screen.getByTestId("password-input"), "SecurePassword123");
    await user.type(
      screen.getByTestId("confirm-password-input"),
      "SecurePassword123",
    );

    await user.click(screen.getByRole("button", { name: /register/i }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        /email already registered/i,
      );
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  it("should display an error message if username already exists", async () => {
    server.use(
      http.post("http://localhost:8000/api/v1/register", () => {
        return HttpResponse.json(
          { detail: "Username already registered" },
          { status: 400 },
        );
      }),
    );

    renderWithProviders(<RegistrationForm />);
    const user = userEvent.setup();

    await user.type(
      screen.getByRole("textbox", { name: /username/i }),
      "existinguser",
    );
    await user.type(
      screen.getByRole("textbox", { name: /email address/i }),
      "test@example.com",
    );
    await user.type(screen.getByTestId("password-input"), "SecurePassword123");
    await user.type(
      screen.getByTestId("confirm-password-input"),
      "SecurePassword123",
    );

    await user.click(screen.getByRole("button", { name: /register/i }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        /username already registered/i,
      );
    });
    expect(mockPush).not.toHaveBeenCalled();
  });

  it("should display a generic error message for unexpected server errors", async () => {
    server.use(
      http.post("http://localhost:8000/api/v1/register", () => {
        return HttpResponse.json(
          { detail: "Internal Server Error" },
          { status: 500 },
        );
      }),
    );

    renderWithProviders(<RegistrationForm />);
    const user = userEvent.setup();

    await user.type(
      screen.getByRole("textbox", { name: /username/i }),
      "testuser",
    );
    await user.type(
      screen.getByRole("textbox", { name: /email address/i }),
      "test@example.com",
    );
    await user.type(screen.getByTestId("password-input"), "SecurePassword123");
    await user.type(
      screen.getByTestId("confirm-password-input"),
      "SecurePassword123",
    );

    await user.click(screen.getByRole("button", { name: /register/i }));

    await waitFor(() => {
      expect(screen.getByRole("alert")).toHaveTextContent(
        /an unexpected error occurred. please try again./i,
      );
    });
    expect(mockPush).not.toHaveBeenCalled();
  });
});

