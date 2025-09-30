"use client";

import React, { useState, useEffect } from "react";
import { TextField, Button, Box, Alert } from "@mui/material";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { useRouter } from "next/navigation";
import { useRegisterMutation } from "@/store/auth/authApi";

const registrationSchema = z
  .object({
    username: z
      .string()
      .min(3, "Username is required and must be at least 3 characters")
      .max(50, "Username cannot exceed 50 characters"),
    email: z.string().email("Invalid email address"),
    password: z
      .string()
      .min(8, "Password is required and must be at least 8 characters"),
    passwordConfirm: z.string().min(1, "Password confirmation is required"),
  })
  .refine((data) => data.password === data.passwordConfirm, {
    message: "Passwords don't match",
    path: ["passwordConfirm"],
  });

type RegistrationFormInputs = z.infer<typeof registrationSchema>;

export default function RegistrationForm() {
  const router = useRouter();
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const [registerUser, { isLoading, isSuccess, isError, error }] =
    useRegisterMutation();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<RegistrationFormInputs>({
    resolver: zodResolver(registrationSchema),
  });

  const onSubmit = async (data: RegistrationFormInputs) => {
    setSuccessMessage(null);
    setErrorMessage(null);
    await registerUser({
      username: data.username,
      email: data.email,
      password: data.password,
    });
  };

  useEffect(() => {
    if (isSuccess) {
      setSuccessMessage("Registration successful! Redirecting to login...");
      setTimeout(() => {
        router.push("/login");
      }, 2000);
    }
    if (isError) {
      interface ApiError {
        status: number;
        data: {
          detail: string;
        };
      }
      const errorData = error as ApiError;
      if (errorData && errorData.status === 500) {
        setErrorMessage("An unexpected error occurred. Please try again.");
      } else if (errorData && errorData.data && errorData.data.detail) {
        setErrorMessage(errorData.data.detail);
      } else {
        setErrorMessage("An unexpected error occurred. Please try again.");
      }
    }
  }, [isSuccess, isError, error, router]);

  return (
    <Box
      component="form"
      onSubmit={handleSubmit(onSubmit)}
      noValidate
      sx={{ mt: 1 }}
    >
      {successMessage && (
        <Alert severity="success" sx={{ mb: 2 }}>
          {successMessage}
        </Alert>
      )}
      {errorMessage && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {errorMessage}
        </Alert>
      )}
      <TextField
        margin="normal"
        required
        fullWidth
        id="username"
        label="Username"
        name="username"
        autoComplete="username"
        autoFocus
        aria-label="Username"
        {...register("username")}
        error={!!errors.username}
        helperText={errors.username?.message}
        disabled={isLoading}
      />
      <TextField
        margin="normal"
        required
        fullWidth
        id="email"
        label="Email Address"
        name="email"
        autoComplete="email"
        aria-label="Email Address"
        {...register("email")}
        error={!!errors.email}
        helperText={errors.email?.message}
        disabled={isLoading}
      />
      <TextField
        margin="normal"
        required
        fullWidth
        name="password"
        label="Password"
        type="password"
        id="password"
        autoComplete="new-password"
        aria-label="Password"
        {...register("password")}
        error={!!errors.password}
        helperText={errors.password?.message}
        disabled={isLoading}
        inputProps={{ "data-testid": "password-input" }}
      />
      <TextField
        margin="normal"
        required
        fullWidth
        name="passwordConfirm"
        label="Confirm Password"
        type="password"
        id="passwordConfirm"
        autoComplete="new-password"
        aria-label="Confirm Password"
        {...register("passwordConfirm")}
        error={!!errors.passwordConfirm}
        helperText={errors.passwordConfirm?.message}
        disabled={isLoading}
        inputProps={{ "data-testid": "confirm-password-input" }}
      />
      <Button
        type="submit"
        fullWidth
        variant="contained"
        sx={{ mt: 3, mb: 2 }}
        disabled={isLoading}
      >
        {isLoading ? "Registering..." : "Register"}
      </Button>
    </Box>
  );
}
