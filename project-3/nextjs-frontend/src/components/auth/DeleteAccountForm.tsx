import React from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  Box,
  Button,
  TextField,
  Typography,
  CircularProgress,
  Alert,
} from "@mui/material";

const deleteAccountSchema = z.object({
  password: z.string().min(1, "Password is required"),
});

type DeleteAccountFormInputs = z.infer<typeof deleteAccountSchema>;

interface DeleteAccountFormProps {
  onConfirm: (data: { password: string }) => void;
  onCancel: () => void;
  isSubmitting: boolean;
  formError?: string;
}

const DeleteAccountForm: React.FC<DeleteAccountFormProps> = ({
  onConfirm,
  onCancel,
  isSubmitting,
  formError,
}) => {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<DeleteAccountFormInputs>({
    resolver: zodResolver(deleteAccountSchema),
  });

  const onSubmit = (data: DeleteAccountFormInputs) => {
    onConfirm({ password: data.password });
  };

  return (
    <Box
      component="form"
      onSubmit={handleSubmit(onSubmit)}
      sx={{
        mt: 3,
        maxWidth: 400,
        mx: "auto",
        p: 3,
        boxShadow: 3,
        borderRadius: 2,
      }}
    >
      <Typography variant="h5" component="h1" gutterBottom align="center">
        Delete Account
      </Typography>
      <Typography
        variant="body2"
        align="center"
        sx={{ mb: 2, color: 'text.secondary' }}
      >
        Are you sure you want to delete your account? This action cannot be
        undone. Please re-enter your password to confirm.
      </Typography>

      {formError && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {formError}
        </Alert>
      )}

      <TextField
        margin="normal"
        required
        fullWidth
        id="password"
        label="Password"
        type="password"
        autoComplete="current-password"
        {...register("password")}
        error={!!errors.password}
        helperText={errors.password?.message}
        disabled={isSubmitting}
        inputProps={{ "data-testid": "password-input" }}
      />

      <Button
        type="submit"
        fullWidth
        variant="contained"
        color="error"
        sx={{ mt: 3, mb: 2 }}
        disabled={isSubmitting}
        data-testid="submit-button"
      >
        {isSubmitting ? (
          <CircularProgress size={24} color="inherit" />
        ) : (
          "Delete My Account"
        )}
      </Button>
      <Button
        type="button"
        fullWidth
        variant="outlined"
        sx={{ mb: 2 }}
        onClick={onCancel}
        disabled={isSubmitting}
      >
        Cancel
      </Button>
    </Box>
  );
};

export default DeleteAccountForm;
