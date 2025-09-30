
import React from 'react';
import { TextField, Button, Box, Typography } from '@mui/material';
import { useForm, SubmitHandler } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

interface ChangePasswordFormProps {
  onSubmit: (data: ChangePasswordFormInputs) => void;
  isSubmitting: boolean;
}

const passwordSchema = z.object({
  current_password: z.string().min(1, 'Current password is required'),
  new_password: z.string()
    .min(8, 'New password must be at least 8 characters long')
    .regex(/[A-Z]/, 'New password must contain at least one uppercase letter')
    .regex(/[a-z]/, 'New password must contain at least one lowercase letter')
    .regex(/[0-9]/, 'New password must contain at least one number')
    .regex(/[^a-zA-Z0-9]/, 'New password must contain at least one special character'),
  confirm_new_password: z.string().min(1, 'Confirm new password is required'),
}).refine((data) => data.new_password === data.confirm_new_password, {
  message: 'New passwords do not match',
  path: ['confirm_new_password'],
});

type ChangePasswordFormInputs = z.infer<typeof passwordSchema>;

const ChangePasswordForm: React.FC<ChangePasswordFormProps> = ({ onSubmit, isSubmitting }) => {
  const { register, handleSubmit, formState: { errors } } = useForm<ChangePasswordFormInputs>({
    resolver: zodResolver(passwordSchema),
  });

  const handleFormSubmit: SubmitHandler<ChangePasswordFormInputs> = (data) => {
    onSubmit(data);
  };

  return (
    <Box component="form" onSubmit={handleSubmit(handleFormSubmit)} sx={{ mt: 3 }}>
      <Typography variant="h6" gutterBottom>
        Change Password
      </Typography>
      <TextField
        margin="normal"
        fullWidth
        name="current_password"
        label="Current Password"
        type="password"
        id="current_password"
        autoComplete="current-password"
        {...register('current_password')}
        error={!!errors.current_password}
        helperText={errors.current_password?.message}
      />
      <TextField
        margin="normal"
        fullWidth
        name="new_password"
        label="New Password"
        type="password"
        id="new_password"
        autoComplete="new-password"
        {...register('new_password')}
        error={!!errors.new_password}
        helperText={errors.new_password?.message}
      />
      <TextField
        margin="normal"
        fullWidth
        name="confirm_new_password"
        label="Confirm New Password"
        type="password"
        id="confirm_new_password"
        autoComplete="new-password"
        {...register('confirm_new_password')}
        error={!!errors.confirm_new_password}
        helperText={errors.confirm_new_password?.message}
      />
      <Button
        type="submit"
        fullWidth
        variant="contained"
        sx={{ mt: 3, mb: 2 }}
        disabled={isSubmitting}
      >
        Change Password
      </Button>
    </Box>
  );
};

export default ChangePasswordForm;
