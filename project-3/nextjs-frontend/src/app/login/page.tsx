"use client";

import React from "react";
import { Box, Typography, Container, Link as MuiLink } from "@mui/material";
import Link from "next/link";
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
        <Box sx={{ mt: 2 }}>
          <Typography variant="body2">
            Don't have an account? <MuiLink component={Link} href="/register" variant="body2">Sign Up</MuiLink>
          </Typography>
        </Box>
      </Box>
    </Container>
  );
}
