/**
 * Barcode Parser — Extract part numbers from structured barcode data
 * 
 * Automotive parts often have barcodes with multiple fields:
 * - GS1-128: (01)EAN(10)LOT(21)SERIAL
 * - Delimited: PN:11427566327|MFR:BMW|LOT:2024
 * - JSON: {"partNumber":"11427566327","mfr":"BMW"}
 * - Plain OEM numbers: 11427566327
 * 
 * This parser attempts to extract the part number intelligently.
 */

/**
 * Parse a barcode string and extract the likely part number.
 * 
 * @param {string} rawBarcode - Raw scanned barcode value
 * @returns {string} Extracted part number or original if no pattern matches
 */
export function extractPartNumber(rawBarcode) {
    if (!rawBarcode || typeof rawBarcode !== 'string') {
        return rawBarcode;
    }

    const trimmed = rawBarcode.trim();

    // 1. Try JSON format: {"partNumber":"X"} or {"pn":"X"} or {"part":"X"}
    if (trimmed.startsWith('{')) {
        try {
            const obj = JSON.parse(trimmed);
            const partNum = obj.partNumber || obj.part_number || obj.pn || obj.part || obj.oem || obj.oemNumber;
            if (partNum) {
                console.log(`📦 Extracted from JSON: "${partNum}"`);
                return String(partNum).trim();
            }
        } catch (e) {
            // Not valid JSON, continue
        }
    }

    // 2. Try GS1-128 Application Identifier format: (AI)Value
    // Common AIs: (01)=GTIN, (10)=Batch/Lot, (21)=Serial, (240)=Additional Product ID
    const gs1Match = trimmed.match(/\(240\)([^()]+)/); // AI 240 is "Additional Product Identification"
    if (gs1Match) {
        console.log(`📦 Extracted from GS1 AI(240): "${gs1Match[1]}"`);
        return gs1Match[1].trim();
    }

    // 3. Try delimited format: PN:X or PART:X or OEM:X or PARTNO:X
    const delimPatterns = [
        /(?:^|[|;,\s])(?:PN|PART(?:NO)?|OEM|ARTICLE)[:\s=]+([A-Z0-9\-]+)/i,
        /(?:^|[|;,\s])([A-Z0-9\-]{5,20})(?:[|;,\s]|$)/i, // Fallback: any alphanumeric 5-20 chars
    ];

    for (const pattern of delimPatterns) {
        const match = trimmed.match(pattern);
        if (match && match[1]) {
            const extracted = match[1].trim();
            // Validate it looks like a part number (not a date, not all numbers)
            if (extracted.length >= 5 && /[A-Z]/.test(extracted)) {
                console.log(`📦 Extracted from delimited: "${extracted}"`);
                return extracted;
            }
        }
    }

    // 4. Try to identify OEM-style part numbers (alphanumeric with dashes/dots)
    // Common patterns: 11427953129, 04E115561H, 90915-YZZD1, 15400-PLM-A02
    const oemPattern = /\b([A-Z0-9]{2,}[-\.][A-Z0-9\-\.]{3,18})\b/i;
    const oemMatch = trimmed.match(oemPattern);
    if (oemMatch) {
        console.log(`📦 Detected OEM pattern: "${oemMatch[1]}"`);
        return oemMatch[1].trim();
    }

    // 5. Check if it's a pure alphanumeric code (8-20 chars, mix of letters and numbers)
    const plainPattern = /^([A-Z0-9]{8,20})$/i;
    const plainMatch = trimmed.match(plainPattern);
    if (plainMatch && /[A-Z]/.test(plainMatch[1]) && /[0-9]/.test(plainMatch[1])) {
        console.log(`📦 Detected plain alphanumeric: "${plainMatch[1]}"`);
        return plainMatch[1];
    }

    // 6. If barcode looks like an EAN/UPC (all digits, 8-14 chars), keep it
    // Some manufacturers use EAN codes that are searchable
    if (/^\d{8,14}$/.test(trimmed)) {
        console.log(`📦 Detected EAN/UPC: "${trimmed}"`);
        return trimmed;
    }

    // 7. Last resort: take first contiguous alphanumeric segment ≥ 5 chars
    const segments = trimmed.split(/[^A-Z0-9\-]+/i).filter(s => s.length >= 5);
    if (segments.length > 0) {
        console.log(`📦 Extracted first segment: "${segments[0]}"`);
        return segments[0];
    }

    // No pattern matched, return as-is
    console.log(`📦 No pattern matched, using raw value: "${trimmed}"`);
    return trimmed;
}

/**
 * Extract additional metadata from barcode if available.
 * 
 * @param {string} rawBarcode - Raw scanned barcode value
 * @returns {Object} Metadata like manufacturer, lot, serial, date
 */
export function extractBarcodeMetadata(rawBarcode) {
    if (!rawBarcode || typeof rawBarcode !== 'string') {
        return {};
    }

    const metadata = {};
    const trimmed = rawBarcode.trim();

    // Try JSON
    if (trimmed.startsWith('{')) {
        try {
            const obj = JSON.parse(trimmed);
            return {
                manufacturer: obj.manufacturer || obj.mfr || obj.brand || null,
                lot: obj.lot || obj.batch || null,
                serial: obj.serial || obj.serialNumber || null,
                date: obj.date || obj.manufacturingDate || null,
            };
        } catch (e) {
            // Continue to other parsers
        }
    }

    // Try GS1-128 common AIs
    const lotMatch = trimmed.match(/\(10\)([^()]+)/);
    if (lotMatch) metadata.lot = lotMatch[1].trim();

    const serialMatch = trimmed.match(/\(21\)([^()]+)/);
    if (serialMatch) metadata.serial = serialMatch[1].trim();

    const dateMatch = trimmed.match(/\(11\)(\d{6})/); // YYMMDD format
    if (dateMatch) metadata.date = dateMatch[1];

    // Try delimited
    const mfrMatch = trimmed.match(/(?:MFR|MANUFACTURER|BRAND)[:\s=]+([^|;,\s]+)/i);
    if (mfrMatch) metadata.manufacturer = mfrMatch[1].trim();

    return metadata;
}

export default { extractPartNumber, extractBarcodeMetadata };
