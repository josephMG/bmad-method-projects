import React from "react";
import * as userApiHooks from "@/store/user/userApi";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";

import * as RHF from "react-hook-form";

vi.mock("react-hook-form", () => ({
  useForm: vi.fn(() => ({
    register: vi.fn(),
    handleSubmit: vi.fn((callback) => (e) => {
      e?.preventDefault();
      callback();
    }),
    formState: { errors: {} },
    reset: vi.fn(),
    setError: vi.fn(),
    clearErrors: vi.fn(),
    setValue: vi.fn(),
    getValues: vi.fn(),
    watch: vi.fn(),
    control: {}, // Mock control object if needed
  })),
}));

const baseMock = {
  register: vi.fn(),
  handleSubmit: (fn: any) => fn,
  control: {} as any,
  setValue: vi.fn(),
  getValues: vi.fn(),
  reset: vi.fn(),
  formState: {
    isSubmitting: false,
    isDirty: false,
    isValid: false,
    touchedFields: {},
    dirtyFields: {},
    submitCount: 0,
    errors: {},
  },
};

import DeleteAccountForm from "@/components/auth/DeleteAccountForm";

describe("DeleteAccountForm", () => {
  const mockOnConfirm = vi.fn();
  const mockOnCancel = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders the form with password field and buttons", () => {
    const mockDeleteUserAccount = vi.fn();

    // spyOn 並 mock 回傳值
    vi.spyOn(userApiHooks, "useDeleteUserAccountMutation").mockReturnValue([
      mockDeleteUserAccount, // [0] trigger 函式
      {
        isLoading: false,
        isSuccess: true,
        isError: false,
        error: undefined,
      },
    ]);

    render(
      <DeleteAccountForm
        onConfirm={mockDeleteUserAccount}
        isSubmitting={false}
        formError={null}
        onCancel={mockOnCancel}
      />,
    );

    expect(screen.getByTestId("password-input")).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: /delete my account/i }),
    ).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /cancel/i })).toBeInTheDocument();
    expect(
      screen.getByRole("heading", { name: /delete account/i }),
    ).toBeInTheDocument();
    expect(
      screen.getByText(/Are you sure you want to delete your account?/i),
    ).toBeInTheDocument();
  });

  it("calls onConfirm with password when form is submitted with valid data", async () => {
    const mockDeleteUserAccount = vi.fn();
    const mockHandleSubmit = vi.fn((callback) => (e) => {
      e?.preventDefault();
      callback({ password: "securepassword123" }); // Simulate form submission with data
    });

    vi.spyOn(userApiHooks, "useDeleteUserAccountMutation").mockReturnValue([
      mockDeleteUserAccount, // [0] trigger 函式
      {
        isLoading: false,
        isSuccess: true,
        isError: false,
        error: undefined,
      },
    ]);

    vi.mocked(RHF.useForm).mockReturnValue({
      register: vi.fn(),
      handleSubmit: mockHandleSubmit,
      formState: { errors: {} },
      reset: vi.fn(),
      setError: vi.fn(),
      clearErrors: vi.fn(),
      setValue: vi.fn(),
      getValues: vi.fn(),
      watch: vi.fn(),
      control: {}, // Mock control object if needed
    });

    render(
      <DeleteAccountForm
        onConfirm={mockDeleteUserAccount}
        isSubmitting={false}
        formError={null}
        onCancel={mockOnCancel}
      />,
    );

    const passwordInput = screen.getByTestId("password-input");
    const submitButton = screen.getByRole("button", {
      name: /delete my account/i,
    });

    fireEvent.change(passwordInput, { target: { value: "securepassword123" } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockDeleteUserAccount).toHaveBeenCalledTimes(1);
      expect(mockDeleteUserAccount).toHaveBeenCalledWith({
        password: "securepassword123",
      });
    });
  });

  it("displays validation error if password is empty", async () => {
    const mockDeleteUserAccount = vi.fn();

    vi.spyOn(userApiHooks, "useDeleteUserAccountMutation").mockReturnValue([
      mockDeleteUserAccount, // [0] trigger 函式
      {
        isLoading: false,
        isSuccess: false,
        isError: true,
        error: { data: { detail: null } },
      },
    ]);

    // Mock useForm to return an error for the password field
    vi.mocked(RHF.useForm).mockReturnValue({
      register: vi.fn(),
      handleSubmit: vi.fn((callback) => (e) => {
        e?.preventDefault();
        callback();
      }),
      formState: {
        errors: {
          password: { type: "required", message: "Password is required" },
        },
      },
      reset: vi.fn(),
      setError: vi.fn(),
      clearErrors: vi.fn(),
      setValue: vi.fn(),
      getValues: vi.fn(),
      watch: vi.fn(),
      control: {}, // Mock control object if needed
    });

    render(
      <DeleteAccountForm
        onConfirm={mockDeleteUserAccount}
        isSubmitting={false}
        formError={null}
        onCancel={mockOnCancel}
      />,
    );

    const passwordInput = screen.getByTestId("password-input"); // Get the input field
    const submitButton = screen.getByRole("button", {
      name: /delete my account/i,
    });

    fireEvent.change(passwordInput, { target: { value: "" } }); // Clear the input
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText(/password is required/i)).toBeInTheDocument();
    });
    expect(mockDeleteUserAccount).not.toHaveBeenCalled();
  });

  it("displays formError prop", () => {
    const testError = "API error message";
    render(
      <DeleteAccountForm
        onConfirm={mockOnConfirm}
        isSubmitting={false}
        formError={testError}
        onCancel={mockOnCancel}
      />,
    );

    expect(screen.getByText(testError)).toBeInTheDocument();
  });

  it("disables buttons and input when isSubmitting is true", () => {
    const mockDeleteUserAccount = vi.fn();

    // spyOn 並 mock 回傳值
    vi.spyOn(userApiHooks, "useDeleteUserAccountMutation").mockReturnValue([
      mockDeleteUserAccount, // [0] trigger 函式
      {
        isLoading: true,
        isSuccess: false,
        isError: false,
        error: undefined,
      },
    ]);

    render(
      <DeleteAccountForm
        onConfirm={mockDeleteUserAccount}
        isSubmitting={true}
        formError={null}
        onCancel={mockOnCancel}
      />,
    );

    expect(screen.getByTestId("password-input")).toBeDisabled();
    expect(screen.getByTestId("submit-button")).toBeDisabled();
    expect(screen.getByRole("progressbar")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /cancel/i })).toBeDisabled();
  });

  it("calls onCancel when cancel button is clicked", () => {
    render(
      <DeleteAccountForm
        onConfirm={mockOnConfirm}
        isSubmitting={false}
        formError={null}
        onCancel={mockOnCancel}
      />,
    );

    fireEvent.click(screen.getByRole("button", { name: /cancel/i }));
    expect(mockOnCancel).toHaveBeenCalledTimes(1);
  });
});
