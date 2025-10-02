"use client";

import React from "react";
import { Box, Container, Typography, Snackbar, Alert } from "@mui/material";
import DeleteAccountForm from "@/components/auth/DeleteAccountForm";
import { useRouter } from "next/navigation";
import { useDeleteUserAccountMutation } from "@/store/user/userApi";
import { useDispatch } from "react-redux";
import { logout } from "@/store/auth/authSlice";

const DeleteAccountPage: React.FC = () => {
  const router = useRouter();
  const dispatch = useDispatch();
  const [deleteUserAccount, { isLoading, isSuccess, isError, error }] =
    useDeleteUserAccountMutation();
  const [snackbarOpen, setSnackbarOpen] = React.useState(false);
  const [snackbarMessage, setSnackbarMessage] = React.useState("");
  const [snackbarSeverity, setSnackbarSeverity] = React.useState<
    "success" | "error" | "info" | "warning"
  >("info");

  React.useEffect(() => {
    if (isSuccess) {
      setSnackbarMessage("Account deleted successfully. Redirecting...");
      setSnackbarSeverity("success");
      setSnackbarOpen(true);
      dispatch(logout());
      setTimeout(() => {
        router.push("/");
      }, 3000);
    } else if (isError) {
      const errorMessage =
        (error as any)?.data?.detail ||
        "Failed to delete account. Please try again.";
      setSnackbarMessage(errorMessage);
      setSnackbarSeverity("error");
      setSnackbarOpen(true);
    }
  }, [isSuccess, isError, error, router, dispatch]);

  const handleConfirmDelete = async (password: string) => {
    await deleteUserAccount({ password });
  };

  const handleCancelDelete = () => {
    router.back();
  };

  const handleCloseSnackbar = () => {
    setSnackbarOpen(false);
  };

  return (
    <Container maxWidth="sm">
      <Box sx={{ my: 4 }}>
        <DeleteAccountForm
          onConfirm={handleConfirmDelete}
          onCancel={handleCancelDelete}
          isSubmitting={isLoading}
          formError={isError ? (error as any)?.data?.detail : undefined}
        />
      </Box>
      <Snackbar
        open={snackbarOpen}
        autoHideDuration={6000}
        onClose={handleCloseSnackbar}
      >
        <Alert
          onClose={handleCloseSnackbar}
          severity={snackbarSeverity}
          sx={{ width: "100%" }}
        >
          {snackbarMessage}
        </Alert>
      </Snackbar>
    </Container>
  );
};

export default DeleteAccountPage;

