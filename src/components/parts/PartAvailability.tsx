import { Paper, Stack, Text, Group, Badge, Progress, Button } from '@mantine/core';
import { MdCheckCircle, MdSchedule, MdWarning, MdCancel } from 'react-icons/md';
import { FiTruck, FiClock } from 'react-icons/fi';

interface SupplierStock {
    supplier: string;
    supplierType: 'OEM' | 'Aftermarket' | 'Dealer';
    partNumber: string;
    stockStatus: 'in-stock' | 'low-stock' | 'out-of-stock' | 'backordered';
    quantity?: number;
    deliveryTime: string;
    price: number;
    location: string;
}

interface PartAvailabilityProps {
    partName: string;
    stockData: SupplierStock[];
}

export function PartAvailability({ partName, stockData }: PartAvailabilityProps) {
    // Status configuration
    const getStatusConfig = (status: string) => {
        switch (status) {
            case 'in-stock':
                return {
                    icon: MdCheckCircle,
                    color: '#10b981', // Green
                    label: 'In Stock',
                    bgColor: '#10b98115',
                };
            case 'low-stock':
                return {
                    icon: MdWarning,
                    color: '#f59e0b', // Amber
                    label: 'Low Stock',
                    bgColor: '#f59e0b15',
                };
            case 'out-of-stock':
                return {
                    icon: MdCancel,
                    color: '#ef4444', // Red
                    label: 'Out of Stock',
                    bgColor: '#ef444415',
                };
            case 'backordered':
                return {
                    icon: MdSchedule,
                    color: '#6366f1', // Indigo
                    label: 'Backordered',
                    bgColor: '#6366f115',
                };
            default:
                return {
                    icon: MdWarning,
                    color: '#6b7280', // Gray
                    label: 'Unknown',
                    bgColor: '#6b728015',
                };
        }
    };

    // Sort by availability and price
    const sortedStock = [...stockData].sort((a, b) => {
        // Priority: in-stock > low-stock > backordered > out-of-stock
        const statusPriority = {
            'in-stock': 1,
            'low-stock': 2,
            'backordered': 3,
            'out-of-stock': 4,
        };

        const aPriority = statusPriority[a.stockStatus] || 5;
        const bPriority = statusPriority[b.stockStatus] || 5;

        if (aPriority !== bPriority) {
            return aPriority - bPriority;
        }

        // If same status, sort by price
        return a.price - b.price;
    });

    const inStockCount = stockData.filter(item => item.stockStatus === 'in-stock').length;
    const totalSuppliers = stockData.length;

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
            {/* Red dot indicator and connecting line */}
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
                {/* Header */}
                <div>
                    <Group justify="space-between" align="center" mb="xs">
                        <Text ff="Inter" fw={600} size="lg" c="#0a0a0a">
                            Part Availability
                        </Text>
                        <Badge
                            color={inStockCount > 0 ? 'green' : 'red'}
                            variant="dot"
                            size="lg"
                            ff="Inter"
                            fw={500}
                        >
                            {inStockCount}/{totalSuppliers} Available
                        </Badge>
                    </Group>

                    <Text ff="Inter" size="sm" c="#52525b">
                        {partName}
                    </Text>

                    {/* Availability Progress Bar */}
                    <div style={{ marginTop: '12px' }}>
                        <Group justify="space-between" mb="xs">
                            <Text ff="Inter" size="xs" c="#52525b">
                                Stock Level Across Suppliers
                            </Text>
                            <Text ff="Inter" size="xs" c="#52525b">
                                {Math.round((inStockCount / totalSuppliers) * 100)}% Available
                            </Text>
                        </Group>
                        <Progress
                            value={(inStockCount / totalSuppliers) * 100}
                            color={inStockCount > totalSuppliers / 2 ? 'green' : inStockCount > 0 ? 'yellow' : 'red'}
                            size="sm"
                            radius="sm"
                        />
                    </div>
                </div>

                {/* Supplier List */}
                <Stack gap="sm">
                    {sortedStock.map((supplier, index) => {
                        const statusConfig = getStatusConfig(supplier.stockStatus);
                        const StatusIcon = statusConfig.icon;

                        return (
                            <Paper
                                key={index}
                                bg="#ffffff"
                                p="md"
                                radius="sm"
                                style={{
                                    border: '1px solid #e4e4e7',
                                    borderLeft: `4px solid ${statusConfig.color}`, // Status indicator line
                                    position: 'relative',
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

                                <Group justify="space-between" align="flex-start">
                                    <div style={{ flex: 1 }}>
                                        <Group gap="sm" align="center" mb="xs">
                                            <StatusIcon size={18} style={{ color: statusConfig.color }} />
                                            <div>
                                                <Text ff="Inter" fw={600} size="sm" c="#0a0a0a">
                                                    {supplier.supplier}
                                                </Text>
                                                <Badge
                                                    size="xs"
                                                    variant="light"
                                                    color={supplier.supplierType === 'OEM' ? 'blue' : supplier.supplierType === 'Dealer' ? 'green' : 'gray'}
                                                    ff="Inter"
                                                >
                                                    {supplier.supplierType}
                                                </Badge>
                                            </div>
                                        </Group>

                                        <Group gap="lg" align="center">
                                            {/* Status Badge */}
                                            <Badge
                                                variant="light"
                                                size="sm"
                                                ff="Inter"
                                                fw={500}
                                                style={{
                                                    backgroundColor: statusConfig.bgColor,
                                                    color: statusConfig.color,
                                                }}
                                            >
                                                {statusConfig.label}
                                                {supplier.quantity && ` (${supplier.quantity})`}
                                            </Badge>

                                            {/* Delivery Time */}
                                            <Group gap="xs" align="center">
                                                <FiTruck size={14} style={{ color: '#52525b' }} />
                                                <Text ff="Inter" size="xs" c="#52525b">
                                                    {supplier.deliveryTime}
                                                </Text>
                                            </Group>

                                            {/* Location */}
                                            <Text ff="Inter" size="xs" c="#52525b">
                                                {supplier.location}
                                            </Text>
                                        </Group>
                                    </div>

                                    <div style={{ textAlign: 'right' }}>
                                        <Text ff="Inter" fw={600} size="md" c="#0a0a0a">
                                            ${supplier.price.toFixed(2)}
                                        </Text>
                                        <Text ff="JetBrains Mono" size="xs" c="#52525b">
                                            {supplier.partNumber}
                                        </Text>
                                    </div>
                                </Group>

                                {/* Quick Action Buttons */}
                                <Group gap="xs" mt="sm">
                                    <Button
                                        size="xs"
                                        variant="light"
                                        color="blue.4"
                                        disabled={supplier.stockStatus === 'out-of-stock'}
                                        ff="Inter"
                                        style={{
                                            minHeight: '32px',
                                            fontSize: '12px',
                                        }}
                                    >
                                        Add to Cart
                                    </Button>

                                    <Button
                                        size="xs"
                                        variant="outline"
                                        color="gray"
                                        ff="Inter"
                                        style={{
                                            minHeight: '32px',
                                            fontSize: '12px',
                                        }}
                                    >
                                        Get Quote
                                    </Button>
                                </Group>
                            </Paper>
                        );
                    })}
                </Stack>

                {/* Summary Actions */}
                <Paper bg="#f4f4f5" p="md" radius="sm" style={{ border: '1px solid #e4e4e7' }}>
                    <Group justify="space-between" align="center">
                        <div>
                            <Text ff="Inter" fw={600} size="sm" c="#0a0a0a">
                                Best Available Option
                            </Text>
                            <Text ff="Inter" size="xs" c="#52525b">
                                {sortedStock[0]?.supplier} - {sortedStock[0]?.deliveryTime} - ${sortedStock[0]?.price.toFixed(2)}
                            </Text>
                        </div>
                        <Button
                            leftSection={<FiClock size={16} />}
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
                            Set Alerts
                        </Button>
                    </Group>
                </Paper>
            </Stack>
        </Paper>
    );
}

export default PartAvailability;