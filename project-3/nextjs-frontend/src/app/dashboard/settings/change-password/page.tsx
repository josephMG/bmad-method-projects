
'use client';

import React, { useState } from 'react';
import { Box, CircularProgress, Alert, Container, Snackbar } from '@mui/material';
import ChangePasswordForm from '@/components/auth/ChangePasswordForm';
import { useChangePasswordMutation } from '@/store/user/userApi';
import { useAppDispatch } from '@/store/hooks';
import { logout } from '@/store/auth/authSlice';
import { useRouter } from 'next/navigation';

const ChangePasswordPage = () => {
  const dispatch = useAppDispatch();
  const router = useRouter();
  const [changePassword, { isLoading: isChangingPassword }] = useChangePasswordMutation();
  const [snackbarOpen, setSnackbarOpen] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [snackbarSeverity, setSnackbarSeverity] = useState<'success' | 'error' | 'info' | 'warning'>('success');

  const handleSnackbarClose = () => {
    setSnackbarOpen(false);
  };

  const handleSubmit = async (formData: any) => {
    try {
      const { current_password, new_password } = formData;
      await changePassword({ current_password, new_password }).unwrap();
      setSnackbarMessage('Password changed successfully! Please log in again.');
      setSnackbarSeverity('success');
      setSnackbarOpen(true);
      dispatch(logout());
      router.push('/login');
    } catch (err: any) {
      const errorMessage = err.data?.detail || 'Failed to change password. Please try again.';
      setSnackbarMessage(errorMessage);
      setSnackbarSeverity('error');
      setSnackbarOpen(true);
      console.error('Failed to change password:', err);
    }
  };

  return (
    <Container maxWidth="sm" sx={{ mt: 4 }}>
      <ChangePasswordForm onSubmit={handleSubmit} isSubmitting={isChangingPassword} />
      <Snackbar open={snackbarOpen} autoHideDuration={6000} onClose={handleSnackbarClose}>
        <Alert onClose={handleSnackbarClose} severity={snackbarSeverity} sx={{ width: '100%' }} role="alert">
          {snackbarMessage}
        </Alert>
      </Snackbar>
    </Container>
  );
};

export default ChangePasswordPage;
