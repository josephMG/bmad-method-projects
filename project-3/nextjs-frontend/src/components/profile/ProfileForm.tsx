
import React, { useEffect } from 'react';
import { TextField, Button, Box, Typography } from '@mui/material';
import { useForm, SubmitHandler } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

interface UserRead {
  id: string;
  email: string;
  username: string;
  full_name: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

interface UserUpdate {
  full_name?: string | null;
  email?: string;
}

interface ProfileFormProps {
  user: UserRead;
  onSubmit: (data: UserUpdate) => void;
  isSubmitting: boolean;
}

const profileSchema = z.object({
  email: z.string().email('Invalid email format').optional().or(z.literal('')),
  full_name: z.string().max(100, 'Full name must be 100 characters or less').optional().or(z.literal('')),
});

type ProfileFormInputs = z.infer<typeof profileSchema>;

const ProfileForm: React.FC<ProfileFormProps> = ({ user, onSubmit, isSubmitting }) => {
  const { register, handleSubmit, reset, formState: { errors } } = useForm<ProfileFormInputs>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      email: user.email,
      full_name: user.full_name || '',
    },
  });

  useEffect(() => {
    reset({
      email: user.email,
      full_name: user.full_name || '',
    });
  }, [user, reset]);

  const handleFormSubmit: SubmitHandler<ProfileFormInputs> = (data) => {
    const updatedData: UserUpdate = {};
    if (data.email !== user.email) {
      updatedData.email = data.email;
    }
    if (data.full_name !== user.full_name) {
      updatedData.full_name = data.full_name;
    }
    onSubmit(updatedData);
  };

  return (
    <Box component="form" onSubmit={handleSubmit(handleFormSubmit)} sx={{ mt: 3 }}>
      <Typography variant="h6" gutterBottom>
        Profile Information
      </Typography>
      <TextField
        margin="normal"
        fullWidth
        id="username"
        label="Username"
        name="username"
        autoComplete="username"
        value={user.username}
        InputProps={{ readOnly: true }}
        aria-readonly="true"
      />
      <TextField
        margin="normal"
        fullWidth
        id="email"
        label="Email Address"
        autoComplete="email"
        {...register('email')}
        error={!!errors.email}
        helperText={errors.email?.message}
      />
      <TextField
        margin="normal"
        fullWidth
        id="full_name"
        label="Full Name"
        autoComplete="name"
        {...register('full_name')}
        error={!!errors.full_name}
        helperText={errors.full_name?.message}
      />
      <Button
        type="submit"
        fullWidth
        variant="contained"
        sx={{ mt: 3, mb: 2 }}
        disabled={isSubmitting}
      >
        Update Profile
      </Button>
    </Box>
  );
};

export default ProfileForm;