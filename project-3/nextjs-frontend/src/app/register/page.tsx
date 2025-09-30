
import RegistrationForm from '@/components/auth/RegistrationForm';
import { Box, Typography, Container } from '@mui/material';

export default function RegisterPage() {
  return (
    <Container component="main" maxWidth="xs">
      <Box
        sx={{
          marginTop: 8,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        <Typography component="h1" variant="h5">
          Register
        </Typography>
        <RegistrationForm />
      </Box>
    </Container>
  );
}
