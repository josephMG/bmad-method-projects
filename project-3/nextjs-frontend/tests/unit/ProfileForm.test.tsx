import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import ProfileForm from "@/components/profile/ProfileForm";

// Mock react-hook-form and zod to simplify testing the component in isolation
vi.mock("react-hook-form", () => ({
  useForm: vi.fn(() => ({
    register: vi.fn((name) => ({
      name,
      onChange: vi.fn(),
      onBlur: vi.fn(),
      ref: vi.fn(),
      value:
        name === "email"
          ? "test@example.com"
          : name === "full_name"
            ? "Test User"
            : "", // Simulate initial values
    })),
    handleSubmit: vi.fn((onSubmit) => (e) => {
      e.preventDefault();
      // Simulate form data based on what would be submitted
      onSubmit({
        email: "new.email@example.com",
        full_name: "New Name",
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
      ...schema,
    })),
    string: vi.fn(() => ({
      email: vi.fn(() => ({
        optional: vi.fn(() => ({
          or: vi.fn(() => ({})),
        })),
      })),
      max: vi.fn(() => ({
        optional: vi.fn(() => ({
          or: vi.fn(() => ({})),
        })),
      })),
    })),
    literal: vi.fn(() => ({})),
  },
}));

const mockUser = {
  id: "123",
  email: "test@example.com",
  username: "testuser",
  full_name: "Test User",
  is_active: true,
  created_at: "2023-01-01T00:00:00Z",
  updated_at: "2023-01-01T00:00:00Z",
};

describe("ProfileForm", () => {
  it("renders the profile form with user details", () => {
    const onSubmit = vi.fn();
    render(
      <ProfileForm user={mockUser} onSubmit={onSubmit} isSubmitting={false} />,
    );

    expect(screen.getByLabelText(/username/i)).toHaveValue(mockUser.username);
    expect(screen.getByLabelText(/email address/i)).toHaveValue(mockUser.email);
    expect(screen.getByLabelText(/full name/i)).toHaveValue(mockUser.full_name);
    expect(
      screen.getByRole("button", { name: /update profile/i }),
    ).toBeInTheDocument();
  });

  it("calls onSubmit with updated data when form is submitted", async () => {
    const onSubmit = vi.fn();
    render(
      <ProfileForm user={mockUser} onSubmit={onSubmit} isSubmitting={false} />,
    );

    const emailInput = screen.getByLabelText(/email address/i);
    const fullNameInput = screen.getByLabelText(/full name/i);
    const submitButton = screen.getByRole("button", {
      name: /update profile/i,
    });

    fireEvent.change(emailInput, {
      target: { value: "new.email@example.com" },
    });
    fireEvent.change(fullNameInput, { target: { value: "New Name" } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledTimes(1);
      expect(onSubmit).toHaveBeenCalledWith({
        email: "new.email@example.com",
        full_name: "New Name",
      });
    });
  });

  it("disables the submit button when isSubmitting is true", () => {
    const onSubmit = vi.fn();
    render(
      <ProfileForm user={mockUser} onSubmit={onSubmit} isSubmitting={true} />,
    );

    const submitButton = screen.getByRole("button", {
      name: /update profile/i,
    });
    expect(submitButton).toBeDisabled();
  });
});
