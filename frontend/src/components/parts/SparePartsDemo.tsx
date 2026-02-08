import { Stack, Container, Title, Text, Divider } from '@mantine/core';
import { SparePartsList } from './SparePartsList';
import { PartAvailability } from './PartAvailability';
import { PriceComparison } from './PriceComparison';
import { InstallationGuide } from './InstallationGuide';
import type { Hotspot } from '../../types/parts';

// Sample data for demonstration
const sampleHotspot: Hotspot = {
  id: 'headlight-left',
  partName: 'Left Headlight',
  angle: 'front',
  coordinates: { x: 250, y: 320 },
  radius: 40,
  oemPartNumbers: {
    bmw: '63117419629',
    audi: '8V0941043C',
    mercedes: 'A2228203061',
    vw: '5G1941005F',
    porsche: '99763115304',
  },
  aftermarketAlternatives: [
    {
      brand: 'Hella',
      partNumber: '1EL010732041',
      qualityRating: 4.6,
      priceRange: '$650-850',
    },
    {
      brand: 'Magneti Marelli',
      partNumber: '711307023110',
      qualityRating: 4.4,
      priceRange: '$580-720',
    },
  ],
  failureFrequency: {
    rating: 'medium',
    commonIssues: [
      'LED module failure',
      'Condensation buildup',
      'Ballast malfunction',
      'Lens clouding',
    ],
    avgLifespanYears: 6,
    replacementFrequency: 'common',
  },
  supplierCatalogs: {
    bmw: 'https://www.bmw.com/parts',
    audi: 'https://parts.audi.com',
    mercedes: 'https://parts.mercedes-benz.com',
    vw: 'https://parts.vw.com',
    porsche: 'https://parts.porsche.com',
  },
};

const sampleStockData = [
  {
    supplier: 'BMW Dealership',
    supplierType: 'Dealer' as const,
    partNumber: '63117419629',
    stockStatus: 'in-stock' as const,
    quantity: 3,
    deliveryTime: '2-3 business days',
    price: 890.5,
    location: 'Local Dealer',
  },
  {
    supplier: 'AutoZone',
    supplierType: 'Aftermarket' as const,
    partNumber: '1EL010732041',
    stockStatus: 'in-stock' as const,
    quantity: 12,
    deliveryTime: 'Same day',
    price: 750.0,
    location: 'Store #1245',
  },
  {
    supplier: 'FCP Euro',
    supplierType: 'OEM' as const,
    partNumber: '63117419629',
    stockStatus: 'low-stock' as const,
    quantity: 1,
    deliveryTime: '1-2 business days',
    price: 820.0,
    location: 'Online',
  },
];

const sampleInstallationSteps = [
  {
    id: 1,
    title: 'Disconnect Battery',
    description:
      'Always disconnect the negative battery terminal before working on electrical components to prevent short circuits.',
    estimatedTime: '5 min',
    difficulty: 'easy' as const,
    tools: ['10mm socket'],
    warnings: ['Ensure engine is off and cool'],
    tips: 'Use a battery terminal protector spray after reconnection',
  },
  {
    id: 2,
    title: 'Remove Headlight Assembly',
    description:
      'Carefully remove the mounting bolts and disconnect the electrical connector. Support the headlight while removing to prevent damage.',
    estimatedTime: '15 min',
    difficulty: 'moderate' as const,
    tools: ['Phillips screwdriver', 'Torx T25'],
    warnings: ['Handle headlight carefully - very fragile', 'Do not touch LED elements'],
  },
  {
    id: 3,
    title: 'Install New Headlight',
    description:
      'Connect electrical connector first, then position headlight and secure with mounting bolts. Check alignment before final tightening.',
    estimatedTime: '10 min',
    difficulty: 'moderate' as const,
    tools: ['Phillips screwdriver', 'Torx T25'],
    tips: 'Test headlight operation before fully reassembling',
  },
  {
    id: 4,
    title: 'Test and Adjust',
    description:
      'Reconnect battery and test all headlight functions. Adjust beam alignment if necessary using adjustment screws.',
    estimatedTime: '10 min',
    difficulty: 'easy' as const,
    tools: ['Headlight alignment tool'],
  },
];

export function SparePartsDemo() {
  return (
    <Container size="md" py="xl">
      <Stack gap="xl">
        <div>
          <Title order={2} ff="Inter" fw={600} c="#0a0a0a">
            Spare Parts Components Demo
          </Title>
          <Text ff="Inter" size="md" c="#52525b">
            Professional arrow/diagram aesthetic with German Car Medic branding
          </Text>
        </div>

        <Divider color="#e4e4e7" />

        {/* SparePartsList Component */}
        <div>
          <Title order={3} ff="Inter" fw={600} c="#0a0a0a" mb="md">
            Spare Parts List
          </Title>
          <SparePartsList hotspot={sampleHotspot} vehicleMake="bmw" />
        </div>

        <Divider color="#e4e4e7" />

        {/* PartAvailability Component */}
        <div>
          <Title order={3} ff="Inter" fw={600} c="#0a0a0a" mb="md">
            Part Availability
          </Title>
          <PartAvailability partName={sampleHotspot.partName} stockData={sampleStockData} />
        </div>

        <Divider color="#e4e4e7" />

        {/* PriceComparison Component */}
        <div>
          <Title order={3} ff="Inter" fw={600} c="#0a0a0a" mb="md">
            Price Comparison
          </Title>
          <PriceComparison
            partName={sampleHotspot.partName}
            oemPrice={890.5}
            oemPartNumber={sampleHotspot.oemPartNumbers?.bmw || ''}
            aftermarketOptions={sampleHotspot.aftermarketAlternatives || []}
            vehicleMake="BMW"
          />
        </div>

        <Divider color="#e4e4e7" />

        {/* InstallationGuide Component */}
        <div>
          <Title order={3} ff="Inter" fw={600} c="#0a0a0a" mb="md">
            Installation Guide
          </Title>
          <InstallationGuide
            partName={sampleHotspot.partName}
            vehicleModel="BMW 3 Series (F30)"
            totalTime="40-50 min"
            difficulty="moderate"
            steps={sampleInstallationSteps}
            requiredTools={[
              '10mm socket',
              'Phillips screwdriver',
              'Torx T25',
              'Headlight alignment tool',
            ]}
            safetyWarnings={[
              'Always disconnect battery before working on electrical components',
              'Handle headlight assembly with care - very expensive to replace',
              'Ensure proper headlight alignment for safety',
            ]}
          />
        </div>
      </Stack>
    </Container>
  );
}

export default SparePartsDemo;
