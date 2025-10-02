"use client";

import React, { useState, useEffect } from "react";
import { TextField, Button, Box, Alert } from "@mui/material";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { useRouter } from "next/navigation";
import { useLoginMutation } from "@/store/auth/authApi";

const loginSchema = z.object({
  username: z.string().min(1, "Username is required"),
  password: z.string().min(1, "Password is required"),
});

type LoginFormInputs = z.infer<typeof loginSchema>;

export default function LoginForm() {
  const router = useRouter();
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const [loginUser, { isLoading, isSuccess, isError, error }] =
    useLoginMutation();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormInputs>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormInputs) => {
    setSuccessMessage(null);
    setErrorMessage(null);
    await loginUser({
      username: data.username,
      password: data.password,
    });
  };

  useEffect(() => {
    if (isSuccess) {
      setSuccessMessage("Login successful! Redirecting to dashboard...");
      setTimeout(() => {
        router.push("/dashboard"); // Redirect to a protected dashboard page
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
      if (errorData && errorData.status === 401) {
        setErrorMessage("Invalid credentials. Please try again.");
      } else if (errorData && errorData.status === 500) {
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
        autoComplete="username"
        aria-label="Username"
        {...register("username")}
        error={!!errors.username}
        helperText={errors.username?.message}
        disabled={isLoading}
        inputProps={{ "data-testid": "username" }}
      />
      <TextField
        margin="normal"
        required
        fullWidth
        label="Password"
        type="password"
        id="password"
        autoComplete="current-password"
        aria-label="Password"
        {...register("password")}
        error={!!errors.password}
        helperText={errors.password?.message}
        disabled={isLoading}
        inputProps={{ "data-testid": "password-input" }}
      />
      <Button
        type="submit"
        fullWidth
        variant="contained"
        sx={{ mt: 3, mb: 2 }}
        disabled={isLoading}
      >
        {isLoading ? "Logging in..." : "Login"}
      </Button>
    </Box>
  );
}
