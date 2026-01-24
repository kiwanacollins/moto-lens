import { useState } from 'react';
import { SimpleGrid, Paper, Stack, Text, Group, ActionIcon } from '@mantine/core';
import {
    MdDirectionsCar,
    MdSettings,
    MdElectricBolt,
    MdTune,
    MdOilBarrel,
    MdAir,
    MdSpeed
} from 'react-icons/md';
import {
    FiTool,
    FiBattery,
    FiZap,
    FiCpu,
    FiFilter,
    FiThermometer,
    FiCircle,
    FiDisc
} from 'react-icons/fi';
import { PartDetailModal } from '../parts/PartDetailModal';
import type { PartInfo } from '../../types/parts';

// Universal automotive parts that apply to all vehicles
const universalPartsData: Array<{
    id: string;
    name: string;
    icon: React.ElementType;
    category: string;
    description: string;
}> = [
        // Engine & Powertrain
        {
            id: 'engine',
            name: 'Engine Block',
            icon: MdDirectionsCar,
            category: 'Engine',
            description: 'Main engine assembly'
        },
        {
            id: 'transmission',
            name: 'Transmission',
            icon: MdSettings,
            category: 'Powertrain',
            description: 'Gear transmission system'
        },
        {
            id: 'oil-pan',
            name: 'Oil Pan',
            icon: MdOilBarrel,
            category: 'Engine',
            description: 'Engine oil reservoir'
        },
        {
            id: 'air-filter',
            name: 'Air Filter',
            icon: MdAir,
            category: 'Engine',
            description: 'Air intake filtration'
        },
        {
            id: 'spark-plugs',
            name: 'Spark Plugs',
            icon: FiZap,
            category: 'Engine',
            description: 'Ignition components'
        },
        {
            id: 'fuel-pump',
            name: 'Fuel Pump',
            icon: MdOilBarrel,
            category: 'Fuel System',
            description: 'Fuel delivery system'
        },

        // Braking System
        {
            id: 'brake-pads',
            name: 'Brake Pads',
            icon: FiDisc,
            category: 'Brakes',
            description: 'Brake friction material'
        },
        {
            id: 'brake-rotors',
            name: 'Brake Rotors',
            icon: FiCircle,
            category: 'Brakes',
            description: 'Brake disc rotors'
        },
        {
            id: 'brake-calipers',
            name: 'Brake Calipers',
            icon: FiTool,
            category: 'Brakes',
            description: 'Brake clamping mechanism'
        },

        // Electrical System
        {
            id: 'battery',
            name: 'Battery',
            icon: FiBattery,
            category: 'Electrical',
            description: '12V automotive battery'
        },
        {
            id: 'alternator',
            name: 'Alternator',
            icon: MdElectricBolt,
            category: 'Electrical',
            description: 'Charging system generator'
        },
        {
            id: 'starter',
            name: 'Starter Motor',
            icon: MdTune,
            category: 'Electrical',
            description: 'Engine starting motor'
        },
        {
            id: 'headlights',
            name: 'Headlights',
            icon: FiZap,
            category: 'Lighting',
            description: 'Front lighting assembly'
        },
        {
            id: 'tail-lights',
            name: 'Tail Lights',
            icon: FiZap,
            category: 'Lighting',
            description: 'Rear lighting assembly'
        },

        // Cooling System
        {
            id: 'radiator',
            name: 'Radiator',
            icon: FiThermometer,
            category: 'Cooling',
            description: 'Engine cooling radiator'
        },
        {
            id: 'water-pump',
            name: 'Water Pump',
            icon: FiThermometer,
            category: 'Cooling',
            description: 'Coolant circulation pump'
        },
        {
            id: 'thermostat',
            name: 'Thermostat',
            icon: FiThermometer,
            category: 'Cooling',
            description: 'Temperature control valve'
        },

        // Suspension & Steering
        {
            id: 'shock-absorbers',
            name: 'Shock Absorbers',
            icon: FiCircle,
            category: 'Suspension',
            description: 'Suspension dampers'
        },
        {
            id: 'struts',
            name: 'Struts',
            icon: FiCircle,
            category: 'Suspension',
            description: 'Suspension struts'
        },
        {
            id: 'control-arms',
            name: 'Control Arms',
            icon: FiTool,
            category: 'Suspension',
            description: 'Suspension linkage'
        },
        {
            id: 'tie-rods',
            name: 'Tie Rods',
            icon: FiTool,
            category: 'Steering',
            description: 'Steering linkage'
        },
        {
            id: 'power-steering-pump',
            name: 'Power Steering Pump',
            icon: MdTune,
            category: 'Steering',
            description: 'Steering assist pump'
        },

        // Wheels & Tires
        {
            id: 'tires',
            name: 'Tires',
            icon: FiCircle,
            category: 'Wheels',
            description: 'Rubber tires'
        },
        {
            id: 'wheels',
            name: 'Wheels',
            icon: FiCircle,
            category: 'Wheels',
            description: 'Wheel rims'
        },
        {
            id: 'wheel-bearings',
            name: 'Wheel Bearings',
            icon: FiCircle,
            category: 'Wheels',
            description: 'Wheel rotation bearings'
        },

        // Exhaust System
        {
            id: 'exhaust-manifold',
            name: 'Exhaust Manifold',
            icon: MdAir,
            category: 'Exhaust',
            description: 'Exhaust gas collector'
        },
        {
            id: 'catalytic-converter',
            name: 'Catalytic Converter',
            icon: MdAir,
            category: 'Exhaust',
            description: 'Emissions control device'
        },
        {
            id: 'muffler',
            name: 'Muffler',
            icon: MdAir,
            category: 'Exhaust',
            description: 'Exhaust sound dampener'
        },

        // Filters & Fluids
        {
            id: 'oil-filter',
            name: 'Oil Filter',
            icon: FiFilter,
            category: 'Filters',
            description: 'Engine oil filtration'
        },
        {
            id: 'fuel-filter',
            name: 'Fuel Filter',
            icon: FiFilter,
            category: 'Filters',
            description: 'Fuel system filtration'
        },
        {
            id: 'cabin-filter',
            name: 'Cabin Air Filter',
            icon: FiFilter,
            category: 'Filters',
            description: 'Interior air filtration'
        },

        // Belts & Hoses
        {
            id: 'timing-belt',
            name: 'Timing Belt',
            icon: FiTool,
            category: 'Engine',
            description: 'Engine timing belt'
        },
        {
            id: 'serpentine-belt',
            name: 'Serpentine Belt',
            icon: FiTool,
            category: 'Engine',
            description: 'Accessory drive belt'
        },
        {
            id: 'radiator-hoses',
            name: 'Radiator Hoses',
            icon: FiThermometer,
            category: 'Cooling',
            description: 'Coolant system hoses'
        },

        // Electronic Components
        {
            id: 'ecu',
            name: 'Engine Control Unit',
            icon: FiCpu,
            category: 'Electronics',
            description: 'Engine management computer'
        },
        {
            id: 'sensors',
            name: 'Sensors',
            icon: FiCpu,
            category: 'Electronics',
            description: 'Various engine sensors'
        },
        {
            id: 'ignition-coils',
            name: 'Ignition Coils',
            icon: MdElectricBolt,
            category: 'Ignition',
            description: 'Spark generation coils'
        },

        // Body & Interior
        {
            id: 'mirrors',
            name: 'Side Mirrors',
            icon: FiCircle,
            category: 'Body',
            description: 'Exterior mirrors'
        },
        {
            id: 'windshield-wipers',
            name: 'Windshield Wipers',
            icon: FiTool,
            category: 'Body',
            description: 'Windshield cleaning system'
        },
        {
            id: 'door-handles',
            name: 'Door Handles',
            icon: FiTool,
            category: 'Body',
            description: 'Vehicle door handles'
        },

        // HVAC System
        {
            id: 'ac-compressor',
            name: 'A/C Compressor',
            icon: MdSpeed,
            category: 'HVAC',
            description: 'Air conditioning compressor'
        },
        {
            id: 'blower-motor',
            name: 'Blower Motor',
            icon: MdAir,
            category: 'HVAC',
            description: 'Interior air circulation'
        },
        {
            id: 'evaporator',
            name: 'A/C Evaporator',
            icon: FiThermometer,
            category: 'HVAC',
            description: 'Air conditioning evaporator'
        }
    ]; interface PartsGridProps {
    vehicleMake?: string;
    vehicleModel?: string;
    vehicleYear?: number;
}

export function PartsGrid({ vehicleMake, vehicleModel, vehicleYear }: PartsGridProps) {
    const [selectedPart, setSelectedPart] = useState<PartInfo | null>(null);
    const [modalOpened, setModalOpened] = useState(false);
    const [selectedHotspot, setSelectedHotspot] = useState<any>(null);

    const handlePartClick = (partData: typeof universalPartsData[0]) => {
        // Create a simplified PartInfo structure since we'll fetch details from Gemini
        const simplePartInfo: PartInfo = {
            id: partData.id,
            name: partData.name,
            description: partData.description,
            partNumber: 'Universal', // Will be populated by Gemini
            symptoms: [], // Will be populated by Gemini
            spareParts: [] // Will be populated by Gemini
        };

        setSelectedPart(simplePartInfo);
        setSelectedHotspot({
            id: partData.id,
            partName: partData.name,
            angle: 'grid-view',
            coordinates: { x: 0, y: 0 },
            radius: 0
        });
        setModalOpened(true);
    }; const handleCloseModal = () => {
        setModalOpened(false);
        setSelectedPart(null);
        setSelectedHotspot(null);
    };

    return (
        <>
            <Paper
                shadow="sm"
                p={{ base: 'lg', sm: 'xl' }}
                radius="lg"
                withBorder
                bg="white"
                style={{ borderColor: '#e4e4e7' }}
            >
                <Group mb="lg" align="center" gap="md">
                    <div
                        style={{
                            width: '12px',
                            height: '12px',
                            backgroundColor: '#ef4444', // Red dot matching hotspot style
                            borderRadius: '50%',
                            boxShadow: '0 2px 4px rgba(239, 68, 68, 0.3)',
                        }}
                    />
                    <div
                        style={{
                            width: '32px',
                            height: '2px',
                            backgroundColor: '#ef4444',
                        }}
                    />
                    <Text
                        ff="Inter"
                        fw={600}
                        c="#0a0a0a"
                        size="lg"
                    >
                        Vehicle Systems & Components
                    </Text>
                </Group>

                <Text
                    ff="Inter"
                    size="sm"
                    c="#52525b"
                    mb="xl"
                >
                    Click on any system below to view detailed information, common issues, and available parts for your {vehicleYear} {vehicleMake} {vehicleModel}.
                </Text>

                <SimpleGrid
                    cols={{ base: 3, sm: 4, md: 6, lg: 8 }}
                    spacing="md"
                >
                    {universalPartsData.map((part) => {
                        const IconComponent = part.icon;

                        return (
                            <Paper
                                key={part.id}
                                p="md"
                                radius="md"
                                withBorder
                                style={{
                                    cursor: 'pointer',
                                    transition: 'all 0.2s ease',
                                    backgroundColor: '#ffffff',
                                    border: '1px solid #e4e4e7',
                                    position: 'relative',
                                    minHeight: '80px',
                                }}
                                onClick={() => handlePartClick(part)}
                                styles={{
                                    root: {
                                        '&:hover': {
                                            borderColor: '#0ea5e9', // Electric Blue on hover
                                            backgroundColor: '#f8fafc',
                                            transform: 'translateY(-2px)',
                                            boxShadow: '0 4px 12px rgba(14, 165, 233, 0.15)',
                                        },
                                        '&:active': {
                                            transform: 'translateY(0px)',
                                        },
                                    },
                                }}
                            >
                                {/* Red dot indicator */}
                                <div
                                    style={{
                                        position: 'absolute',
                                        top: '12px',
                                        left: '12px',
                                        width: '8px',
                                        height: '8px',
                                        backgroundColor: '#ef4444',
                                        borderRadius: '50%',
                                    }}
                                />

                                <Stack gap="xs" align="center" style={{ textAlign: 'center' }}>
                                    <ActionIcon
                                        size={36}
                                        radius="md"
                                        variant="light"
                                        color="blue.4"
                                        style={{
                                            backgroundColor: '#0ea5e915',
                                            border: '2px solid #0ea5e930',
                                        }}
                                    >
                                        <IconComponent size={20} style={{ color: '#0ea5e9' }} />
                                    </ActionIcon>

                                    <div>
                                        <Text
                                            ff="Inter"
                                            fw={600}
                                            size="xs"
                                            c="#0a0a0a"
                                        >
                                            {part.name}
                                        </Text>
                                    </div>
                                </Stack>
                            </Paper>
                        );
                    })}
                </SimpleGrid>
            </Paper>

            {/* Part Detail Modal */}
            <PartDetailModal
                opened={modalOpened}
                onClose={handleCloseModal}
                partInfo={selectedPart}
                clickedHotspot={selectedHotspot}
                loading={false}
            />
        </>
    );
}

export default PartsGrid;