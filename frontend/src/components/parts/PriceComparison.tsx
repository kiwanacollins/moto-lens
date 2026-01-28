import { Paper, Stack, Text, Group, Badge, Button, Divider } from '@mantine/core';
import { MdStar, MdVerified, MdTrendingUp } from 'react-icons/md';
import { FiDollarSign, FiShield, FiTruck } from 'react-icons/fi';
import type { AftermarketAlternative } from '../../types/parts';

interface PriceOption {
  id: string;
  type: 'OEM' | 'Aftermarket' | 'Used/Refurbished';
  brand: string;
  partNumber: string;
  price: number;
  originalPrice?: number; // For showing discounts
  qualityRating?: number;
  warranty: string;
  deliveryTime: string;
  supplier: string;
  inStock: boolean;
  features: string[];
  recommended?: boolean;
}

interface PriceComparisonProps {
  partName: string;
  oemPrice: number;
  oemPartNumber: string;
  aftermarketOptions: AftermarketAlternative[];
  vehicleMake: string;
}

export function PriceComparison({
  partName,
  oemPrice,
  oemPartNumber,
  aftermarketOptions,
  vehicleMake,
}: PriceComparisonProps) {
  // Create price options array
  const oemOption: PriceOption = {
    id: 'oem',
    type: 'OEM',
    brand: vehicleMake.toUpperCase(),
    partNumber: oemPartNumber,
    price: oemPrice,
    qualityRating: 5.0,
    warranty: '2 years / 24,000 miles',
    deliveryTime: '2-3 business days',
    supplier: `${vehicleMake.toUpperCase()} Dealer`,
    inStock: true,
    features: ['Genuine Part', 'Perfect Fit', 'OEM Warranty'],
    recommended: false,
  };

  // Convert aftermarket alternatives to price options
  const aftermarketPriceOptions: PriceOption[] = aftermarketOptions.map((alt, index) => {
    const priceRange = alt.priceRange.replace(/[$,]/g, '').split('-');
    const avgPrice = (parseFloat(priceRange[0]) + parseFloat(priceRange[1])) / 2;

    return {
      id: `aftermarket-${index}`,
      type: 'Aftermarket',
      brand: alt.brand,
      partNumber: alt.partNumber,
      price: avgPrice,
      originalPrice: avgPrice * 1.15, // Show 15% discount
      qualityRating: alt.qualityRating,
      warranty: '1 year / 12,000 miles',
      deliveryTime: '1-2 business days',
      supplier: 'Auto Parts Store',
      inStock: true,
      features: ['Quality Tested', 'Good Value', 'Fast Shipping'],
      recommended: alt.qualityRating > 4.3,
    };
  });

  // Add a used/refurbished option
  const usedOption: PriceOption = {
    id: 'used',
    type: 'Used/Refurbished',
    brand: 'Various',
    partNumber: 'USED-' + oemPartNumber.slice(-6),
    price: oemPrice * 0.4, // 40% of OEM price
    qualityRating: 3.8,
    warranty: '90 days',
    deliveryTime: '3-5 business days',
    supplier: 'Salvage Yard',
    inStock: true,
    features: ['Budget Option', 'Inspected', 'Limited Warranty'],
    recommended: false,
  };

  const allOptions = [oemOption, ...aftermarketPriceOptions, usedOption];

  // Sort by price
  const sortedOptions = [...allOptions].sort((a, b) => a.price - b.price);

  // Find best value (good quality + reasonable price)
  const bestValueOption = [...allOptions].sort((a, b) => {
    const aValue = (a.qualityRating || 3) / (a.price / 100);
    const bValue = (b.qualityRating || 3) / (b.price / 100);
    return bValue - aValue;
  })[0];

  return (
    <Paper
      shadow="sm"
      p="lg"
      radius="md"
      withBorder
      style={{
        backgroundColor: '#ffffff',
        border: '1px solid #e4e4e7',
        position: 'relative',
      }}
    >
      {/* Red dot and connecting line */}
      <div
        style={{
          position: 'absolute',
          top: '16px',
          left: '16px',
          width: '12px',
          height: '12px',
          backgroundColor: '#ef4444',
          borderRadius: '50%',
          boxShadow: '0 2px 4px rgba(239, 68, 68, 0.3)',
        }}
      />
      <div
        style={{
          position: 'absolute',
          top: '22px',
          left: '28px',
          width: '32px',
          height: '2px',
          backgroundColor: '#ef4444',
        }}
      />

      <Stack gap="lg" style={{ marginLeft: '40px' }}>
        {/* Header with Price Summary */}
        <div>
          <Group justify="space-between" align="flex-start" mb="sm">
            <div>
              <Text ff="Inter" fw={600} size="lg" c="#0a0a0a">
                Price Comparison
              </Text>
              <Text ff="Inter" size="sm" c="#52525b">
                {partName}
              </Text>
            </div>

            <div style={{ textAlign: 'right' }}>
              <Text ff="Inter" size="xs" c="#52525b">
                Price Range
              </Text>
              <Text ff="Inter" fw={600} size="lg" c="#0a0a0a">
                ${Math.min(...allOptions.map(o => o.price)).toFixed(0)} - $
                {Math.max(...allOptions.map(o => o.price)).toFixed(0)}
              </Text>
            </div>
          </Group>

          {/* Savings Indicator */}
          <Paper bg="#10b98115" p="sm" radius="sm" style={{ border: '1px solid #10b98130' }}>
            <Group gap="xs" align="center">
              <MdTrendingUp size={16} style={{ color: '#10b981' }} />
              <Text ff="Inter" fw={500} size="sm" c="#10b981">
                Save up to ${(oemPrice - Math.min(...allOptions.map(o => o.price))).toFixed(0)}(
                {(
                  ((oemPrice - Math.min(...allOptions.map(o => o.price))) / oemPrice) *
                  100
                ).toFixed(0)}
                %)
              </Text>
              <Text ff="Inter" size="xs" c="#52525b">
                vs OEM pricing
              </Text>
            </Group>
          </Paper>
        </div>

        {/* Price Options */}
        <Stack gap="md">
          {sortedOptions.map((option, index) => (
            <Paper
              key={option.id}
              bg="#ffffff"
              p="md"
              radius="sm"
              style={{
                border:
                  option.id === bestValueOption.id
                    ? '2px solid #0ea5e9' // Electric Blue for best value
                    : '1px solid #e4e4e7',
                borderLeft: `4px solid ${option.type === 'OEM' ? '#6366f1' : option.type === 'Aftermarket' ? '#10b981' : '#f59e0b'}`,
                position: 'relative',
                backgroundColor: option.id === bestValueOption.id ? '#0ea5e915' : '#ffffff',
              }}
            >
              {/* Connecting line from main red dot */}
              <div
                style={{
                  position: 'absolute',
                  top: '50%',
                  left: '-12px',
                  width: '8px',
                  height: '2px',
                  backgroundColor: '#ef4444',
                  transform: 'translateY(-50%)',
                }}
              />

              {/* Best Value Badge */}
              {option.id === bestValueOption.id && (
                <Badge
                  leftSection={<MdStar size={12} />}
                  color="blue.4"
                  variant="filled"
                  size="sm"
                  ff="Inter"
                  fw={500}
                  style={{
                    position: 'absolute',
                    top: '8px',
                    right: '8px',
                    backgroundColor: '#0ea5e9',
                  }}
                >
                  Best Value
                </Badge>
              )}

              <Group justify="space-between" align="flex-start">
                <div style={{ flex: 1 }}>
                  <Group gap="sm" align="center" mb="xs">
                    <div>
                      <Group gap="xs" align="center">
                        <Text ff="Inter" fw={600} size="md" c="#0a0a0a">
                          {option.brand}
                        </Text>
                        <Badge
                          size="xs"
                          variant="light"
                          color={
                            option.type === 'OEM'
                              ? 'blue'
                              : option.type === 'Aftermarket'
                                ? 'green'
                                : 'yellow'
                          }
                          ff="Inter"
                        >
                          {option.type}
                        </Badge>
                        {option.recommended && (
                          <MdVerified size={16} style={{ color: '#10b981' }} />
                        )}
                      </Group>

                      <Text ff="JetBrains Mono" size="xs" c="#52525b">
                        {option.partNumber}
                      </Text>
                    </div>
                  </Group>

                  <Group gap="lg" align="center" mb="sm">
                    {/* Quality Rating */}
                    {option.qualityRating && (
                      <Group gap="xs" align="center">
                        <MdStar size={14} style={{ color: '#f59e0b' }} />
                        <Text ff="Inter" size="sm" c="#0a0a0a" fw={500}>
                          {option.qualityRating.toFixed(1)}
                        </Text>
                        <Text ff="Inter" size="xs" c="#52525b">
                          / 5.0
                        </Text>
                      </Group>
                    )}

                    {/* Warranty */}
                    <Group gap="xs" align="center">
                      <FiShield size={14} style={{ color: '#52525b' }} />
                      <Text ff="Inter" size="sm" c="#52525b">
                        {option.warranty}
                      </Text>
                    </Group>

                    {/* Delivery */}
                    <Group gap="xs" align="center">
                      <FiTruck size={14} style={{ color: '#52525b' }} />
                      <Text ff="Inter" size="sm" c="#52525b">
                        {option.deliveryTime}
                      </Text>
                    </Group>
                  </Group>

                  {/* Features */}
                  <Group gap="xs">
                    {option.features.slice(0, 3).map((feature, idx) => (
                      <Badge key={idx} size="xs" variant="dot" color="gray" ff="Inter">
                        {feature}
                      </Badge>
                    ))}
                  </Group>
                </div>

                <div style={{ textAlign: 'right' }}>
                  {/* Price Display */}
                  <Group gap="xs" justify="flex-end" align="center">
                    {option.originalPrice && option.originalPrice > option.price && (
                      <Text
                        ff="Inter"
                        size="sm"
                        c="#52525b"
                        style={{ textDecoration: 'line-through' }}
                      >
                        ${option.originalPrice.toFixed(0)}
                      </Text>
                    )}
                    <Text ff="Inter" fw={600} size="xl" c="#0a0a0a">
                      ${option.price.toFixed(0)}
                    </Text>
                  </Group>

                  {/* Savings Badge */}
                  {index > 0 && (
                    <Badge variant="light" color="green" size="sm" ff="Inter" mt="xs">
                      Save ${(oemOption.price - option.price).toFixed(0)}
                    </Badge>
                  )}

                  {/* Stock Status */}
                  <Text ff="Inter" size="xs" c={option.inStock ? '#10b981' : '#ef4444'} mt="xs">
                    {option.inStock ? 'In Stock' : 'Out of Stock'}
                  </Text>
                </div>
              </Group>

              {/* Action Button */}
              <Group justify="flex-end" mt="sm">
                <Button
                  leftSection={<FiDollarSign size={16} />}
                  color={option.id === bestValueOption.id ? 'blue.4' : 'gray'}
                  variant={option.id === bestValueOption.id ? 'filled' : 'outline'}
                  size="sm"
                  ff="Inter"
                  fw={500}
                  disabled={!option.inStock}
                  style={{
                    minHeight: '40px',
                    backgroundColor: option.id === bestValueOption.id ? '#0ea5e9' : undefined,
                  }}
                >
                  {option.inStock ? 'Get Quote' : 'Notify When Available'}
                </Button>
              </Group>
            </Paper>
          ))}
        </Stack>

        <Divider color="#e4e4e7" />

        {/* Summary and Actions */}
        <Paper bg="#f4f4f5" p="md" radius="sm" style={{ border: '1px solid #e4e4e7' }}>
          <Stack gap="sm">
            <Group justify="space-between" align="center">
              <div>
                <Text ff="Inter" fw={600} size="sm" c="#0a0a0a">
                  Recommended Choice
                </Text>
                <Text ff="Inter" size="sm" c="#52525b">
                  {bestValueOption.brand} - Best quality-to-price ratio
                </Text>
              </div>
              <Button
                color="blue.4"
                variant="filled"
                size="sm"
                ff="Inter"
                fw={500}
                style={{
                  backgroundColor: '#0ea5e9',
                  minHeight: '44px',
                }}
              >
                Compare All Options
              </Button>
            </Group>
          </Stack>
        </Paper>
      </Stack>
    </Paper>
  );
}

export default PriceComparison;
