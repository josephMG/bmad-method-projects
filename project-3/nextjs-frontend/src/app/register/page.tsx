
import RegistrationForm from '@/components/auth/RegistrationForm';
import { Box, Typography, Container, Link as MuiLink } from "@mui/material";
import Link from "next/link";

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
        <Box sx={{ mt: 2 }}>
          <Typography variant="body2">
            Already have an account? <MuiLink component={Link} href="/login" variant="body2">Login</MuiLink>
          </Typography>
        </Box>
      </Box>
    </Container>
  );
}
