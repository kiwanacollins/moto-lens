import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

console.log('🎨 MOTO LENS Icon Generator\n');
console.log('📝 To convert SVG to PNG, you have several options:\n');

console.log('Option 1: Install sharp and run conversion');
console.log('─────────────────────────────────────────');
console.log('npm install sharp');
console.log('node scripts/convert-icons.js\n');

console.log('Option 2: Use sharp-cli (recommended)');
console.log('─────────────────────────────────────────');
console.log('npm install -g sharp-cli');
console.log('sharp -i public/logo.svg -o public/icon-512.png resize 512 512');
console.log('sharp -i public/icon-192.svg -o public/icon-192.png resize 192 192');
console.log('sharp -i public/icon-512-maskable.svg -o public/icon-512-maskable.png resize 512 512\n');

console.log('Option 3: Use online converters');
console.log('─────────────────────────────────────────');
console.log('- CloudConvert: https://cloudconvert.com/svg-to-png');
console.log('- Convertio: https://convertio.co/svg-png/');
console.log('- SVGOMG: https://jakearchibald.github.io/svgomg/\n');

console.log('Option 4: Use the browser-based generator');
console.log('─────────────────────────────────────────');
console.log('npm run dev');
console.log('Then open: http://localhost:5173/icon-generator.html\n');

console.log('SVG files created:');
console.log('✓ public/logo.svg (512x512)');
console.log('✓ public/icon-192.svg (192x192)');
console.log('✓ public/icon-512-maskable.svg (512x512)\n');

// Try to use sharp if available
try {
  const sharp = await import('sharp');
  console.log('✓ Sharp is installed! Converting icons...\n');
  
  const publicDir = join(__dirname, '..', 'public');
  
  // Convert logo.svg to icon-512.png
  await sharp.default(join(publicDir, 'logo.svg'))
    .resize(512, 512)
    .png()
    .toFile(join(publicDir, 'icon-512.png'));
  console.log('✓ Created icon-512.png');
  
  // Convert icon-192.svg to icon-192.png
  await sharp.default(join(publicDir, 'icon-192.svg'))
    .resize(192, 192)
    .png()
    .toFile(join(publicDir, 'icon-192.png'));
  console.log('✓ Created icon-192.png');
  
  // Convert icon-512-maskable.svg to icon-512-maskable.png
  await sharp.default(join(publicDir, 'icon-512-maskable.svg'))
    .resize(512, 512)
    .png()
    .toFile(join(publicDir, 'icon-512-maskable.png'));
  console.log('✓ Created icon-512-maskable.png');
  
  console.log('\n🎉 All PNG icons have been generated successfully!');
} catch (error) {
  console.log('⚠️  Sharp is not installed. Use one of the options above to convert SVG to PNG.');
}
