"use client";

import React from "react";
import { Box, Typography, Container } from "@mui/material";
import LoginForm from "@/components/auth/LoginForm";
import { ThemeToggleButton } from "@/components/common/ThemeToggleButton";

export default function LoginPage() {
  return (
    <Container component="main" maxWidth="xs" sx={{ position: 'relative' }}>
      <Box
        sx={{
          marginTop: 8,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
        }}
      >
        <Box sx={{ position: 'absolute', top: 16, right: 16 }}> {/* Added Box for positioning */}
          <ThemeToggleButton />
        </Box>
        <Typography component="h1" variant="h5">
          Login
        </Typography>
        <LoginForm />
      </Box>
    </Container>
  );
}
