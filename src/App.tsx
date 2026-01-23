import { Container, Title, Text, Button, Stack } from '@mantine/core';
import { BRAND_COLORS } from './styles/theme';
import { MotoLensLogo } from './components/MotoLensLogo';

function App() {
  return (
    <Container size="sm" style={{ minHeight: '100vh', paddingTop: '2rem' }}>
      <Stack gap="xl">
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '1rem' }}>
          <MotoLensLogo size={150} />
        </div>
        
        <Title 
          order={1} 
          style={{ 
            color: BRAND_COLORS.electricBlue,
            textAlign: 'center',
            fontSize: '3rem',
          }}
        >
          MOTO LENS
        </Title>
        
        <Text 
          size="lg" 
          style={{ 
            textAlign: 'center',
            color: '#fff',
          }}
        >
          German Vehicle VIN Decoder & Parts Identifier
        </Text>

        <Stack gap="md" style={{ marginTop: '2rem' }}>
          <Button 
            size="lg" 
            fullWidth
            style={{
              backgroundColor: BRAND_COLORS.electricBlue,
              color: BRAND_COLORS.carbonBlack,
            }}
          >
            Get Started
          </Button>
          
          <Text 
            size="sm" 
            style={{ 
              textAlign: 'center',
              color: '#A6A7AB',
              fontFamily: 'JetBrains Mono, monospace',
            }}
          >
            Mantine UI configured with brand colors
          </Text>
        </Stack>

        <Stack gap="xs" style={{ marginTop: '2rem' }}>
          <Text size="sm" fw={600} style={{ color: BRAND_COLORS.electricBlue }}>
            Brand Colors:
          </Text>
          <div style={{ 
            display: 'flex', 
            gap: '1rem', 
            flexWrap: 'wrap',
          }}>
            <div style={{ textAlign: 'center' }}>
              <div style={{ 
                width: '80px', 
                height: '80px', 
                backgroundColor: BRAND_COLORS.carbonBlack,
                border: '2px solid #fff',
                borderRadius: '8px',
              }} />
              <Text size="xs" mt="xs">Carbon Black</Text>
            </div>
            <div style={{ textAlign: 'center' }}>
              <div style={{ 
                width: '80px', 
                height: '80px', 
                backgroundColor: BRAND_COLORS.gunmetalGray,
                borderRadius: '8px',
              }} />
              <Text size="xs" mt="xs">Gunmetal Gray</Text>
            </div>
            <div style={{ textAlign: 'center' }}>
              <div style={{ 
                width: '80px', 
                height: '80px', 
                backgroundColor: BRAND_COLORS.electricBlue,
                borderRadius: '8px',
              }} />
              <Text size="xs" mt="xs">Electric Blue</Text>
            </div>
          </div>
        </Stack>
      </Stack>
    </Container>
  );
}

export default App;
