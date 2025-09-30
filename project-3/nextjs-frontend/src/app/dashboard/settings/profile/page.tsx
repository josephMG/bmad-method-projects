
'use client';

import React, { useState } from 'react';
import { Box, CircularProgress, Alert, Container, Snackbar } from '@mui/material';
import ProfileForm from '@/components/profile/ProfileForm';
import { useGetUserProfileQuery, useUpdateUserProfileMutation } from '@/store/user/userApi';
import { useAppDispatch } from '@/store/hooks';
import { setProfile } from '@/store/user/userSlice';

const ProfilePage = () => {
  const dispatch = useAppDispatch();
  const { data: user, error, isLoading } = useGetUserProfileQuery();
  const [updateUserProfile, { isLoading: isUpdating }] = useUpdateUserProfileMutation();
  const [snackbarOpen, setSnackbarOpen] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [snackbarSeverity, setSnackbarSeverity] = useState<'success' | 'error' | 'info' | 'warning'>('success');

  const handleSnackbarClose = () => {
    setSnackbarOpen(false);
  };

  const handleSubmit = async (formData: any) => {
    try {
      const updatedUser = await updateUserProfile(formData).unwrap();
      dispatch(setProfile(updatedUser));
      setSnackbarMessage('Profile updated successfully!');
      setSnackbarSeverity('success');
      setSnackbarOpen(true);
    } catch (err: any) {
      const errorMessage = err.data?.detail || 'Failed to update profile. Please try again.';
      setSnackbarMessage(errorMessage);
      setSnackbarSeverity('error');
      setSnackbarOpen(true);
      console.error('Failed to update profile:', err);
    }
  };

  if (isLoading) {
    return (
      <Container maxWidth="sm" sx={{ mt: 4, display: 'flex', justifyContent: 'center' }}>
        <CircularProgress />
      </Container>
    );
  }

  if (error) {
    return (
      <Container maxWidth="sm" sx={{ mt: 4 }}>
        <Alert severity="error">Failed to load profile. Please try again later.</Alert>
      </Container>
    );
  }

  if (!user) {
    return (
      <Container maxWidth="sm" sx={{ mt: 4 }}>
        <Alert severity="info">No user profile data available.</Alert>
      </Container>
    );
  }

  return (
    <Container maxWidth="sm" sx={{ mt: 4 }}>
      <ProfileForm user={user} onSubmit={handleSubmit} isSubmitting={isUpdating} />
      <Snackbar open={snackbarOpen} autoHideDuration={6000} onClose={handleSnackbarClose}>
        <Alert onClose={handleSnackbarClose} severity={snackbarSeverity} sx={{ width: '100%' }} role="alert">
          {snackbarMessage}
        </Alert>
      </Snackbar>
    </Container>
  );
};

export default ProfilePage;