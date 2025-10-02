"use client";

import React from "react";
import { Box, Typography, Button } from "@mui/material";
import Link from "next/link";

export default function DashboardPage() {
  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "100vh",
        padding: 2,
      }}
    >
      <Typography variant="h4" component="h1" gutterBottom>
        Welcome to your Dashboard!
      </Typography>
      <Typography variant="body1" gutterBottom>
        This is your central hub.
      </Typography>
      <Box sx={{ mt: 3, display: "flex", gap: 2 }}>
        <Button component={Link} href="/dashboard/settings/profile" variant="contained">
          Profile
        </Button>
        <Button component={Link} href="/dashboard/settings/change-password" variant="contained">
          Change Password
        </Button>
        <Button component={Link} href="/dashboard/settings/delete-account" variant="contained">
          Delete Account
        </Button>
      </Box>
    </Box>
  );
}
