import subprocess
from PIL import Image
import os

# Step 1: Use rsvg-convert to render SVG to a large PNG (transparent bg)
subprocess.run([
    'rsvg-convert',
    '-w', '800', '-h', '800',
    'assets/logo.svg',
    '-o', 'assets/car_temp.png'
], check=True)

car_img = Image.open('assets/car_temp.png').convert('RGBA')

# Step 2: Crop to the actual content (remove transparent padding)
bbox = car_img.getbbox()
if bbox:
    car_img = car_img.crop(bbox)
    print(f'Cropped car to: {car_img.size}')

# Step 3: Create icon canvas: 1024x1024, WHITE background
icon_size = 1024
icon = Image.new('RGBA', (icon_size, icon_size), (255, 255, 255, 255))

# Step 4: Scale car to fit with comfortable padding, maintaining aspect ratio
padding = 140
max_area = icon_size - (padding * 2)
car_w, car_h = car_img.size
scale = min(max_area / car_w, max_area / car_h)
new_w = int(car_w * scale)
new_h = int(car_h * scale)
car_img = car_img.resize((new_w, new_h), Image.LANCZOS)
print(f'Scaled car to: {car_img.size}')

# Step 5: Paste car EXACTLY centered on icon
offset_x = (icon_size - new_w) // 2
offset_y = (icon_size - new_h) // 2
icon.paste(car_img, (offset_x, offset_y), car_img)
print(f'Placed at offset: ({offset_x}, {offset_y})')

# Step 6: Convert to RGB (no alpha) for launcher icon compatibility
icon_rgb = icon.convert('RGB')
icon_rgb.save('assets/icon.png', 'PNG')
print(f'Generated icon.png: {icon_rgb.size}')

# Cleanup
os.remove('assets/car_temp.png')
print('Done!')
