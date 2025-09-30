import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import ChangePasswordForm from "@/components/auth/ChangePasswordForm";

// Mock react-hook-form and zod to simplify testing the component in isolation
vi.mock("react-hook-form", () => ({
  useForm: vi.fn(() => ({
    register: vi.fn((name) => ({
      name,
      onChange: vi.fn(),
      onBlur: vi.fn(),
      ref: vi.fn(),
      value: "",
    })),
    handleSubmit: vi.fn((onSubmit) => (e) => {
      e.preventDefault();
      onSubmit({
        current_password: "CurrentPassword123!",
        new_password: "NewPassword456!",
        confirm_new_password: "NewPassword456!",
      });
    }),
    reset: vi.fn(),
    formState: { errors: {} },
  })),
  Controller: vi.fn(({ render }) =>
    render({
      field: {
        onChange: vi.fn(),
        onBlur: vi.fn(),
        value: "",
        name: "",
        ref: vi.fn(),
      },
      fieldState: {
        invalid: false,
        isDirty: false,
        isTouched: false,
        error: undefined,
      },
      formState: {
        isSubmitted: false,
        dirtyFields: {},
        isSubmitting: false,
        touchedFields: {},
        errors: {},
      },
    }),
  ),
  useFormContext: vi.fn(() => ({
    register: vi.fn(),
    formState: { errors: {} },
    control: {},
  })),
}));

vi.mock("@hookform/resolvers/zod", () => ({
  zodResolver: vi.fn(() => vi.fn()),
}));

vi.mock("zod", () => ({
  z: {
    object: vi.fn((schema) => ({
      parse: vi.fn((data) => data),
      refine: vi.fn(() => ({})),
      ...schema,
    })),
    string: vi.fn(() => ({
      min: vi.fn(() => ({
        regex: vi.fn(() => ({
          regex: vi.fn(() => ({
            regex: vi.fn(() => ({
              regex: vi.fn(() => ({})),
            })),
          })),
        })),
      })),
    })),
  },
}));

describe("ChangePasswordForm", () => {
  it("renders the change password form with all fields", () => {
    const onSubmit = vi.fn();
    render(<ChangePasswordForm onSubmit={onSubmit} isSubmitting={false} />);

    expect(screen.getByLabelText("Current Password")).toBeInTheDocument();
    expect(screen.getByLabelText("New Password")).toBeInTheDocument();
    expect(screen.getByLabelText("Confirm New Password")).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: /change password/i }),
    ).toBeInTheDocument();
  });

  it("calls onSubmit with form data when submitted", async () => {
    const onSubmit = vi.fn();
    render(<ChangePasswordForm onSubmit={onSubmit} isSubmitting={false} />);

    const currentPasswordInput = screen.getByLabelText("Current Password");
    const newPasswordInput = screen.getByLabelText("New Password");
    const confirmNewPasswordInput = screen.getByLabelText(
      "Confirm New Password",
    );
    const submitButton = screen.getByRole("button", {
      name: /change password/i,
    });

    fireEvent.change(currentPasswordInput, {
      target: { value: "CurrentPassword123!" },
    });
    fireEvent.change(newPasswordInput, {
      target: { value: "NewPassword456!" },
    });
    fireEvent.change(confirmNewPasswordInput, {
      target: { value: "NewPassword456!" },
    });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledTimes(1);
      expect(onSubmit).toHaveBeenCalledWith({
        current_password: "CurrentPassword123!",
        new_password: "NewPassword456!",
        confirm_new_password: "NewPassword456!",
      });
    });
  });

  it("disables the submit button when isSubmitting is true", () => {
    const onSubmit = vi.fn();
    render(<ChangePasswordForm onSubmit={onSubmit} isSubmitting={true} />);

    const submitButton = screen.getByRole("button", {
      name: /change password/i,
    });
    expect(submitButton).toBeDisabled();
  });
});
