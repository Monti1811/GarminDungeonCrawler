from PIL import Image
import os

# Open the image
image_path = r"X:\Code\garmin\RPG_Assets\1bit 16px patterns and tiles.png"
output_dir = "font"
os.makedirs(output_dir, exist_ok=True)

img = Image.open(image_path)
tile_size = 16  # Each tile is 16x16 pixels
img_width, img_height = img.size

# Loop through rows and columns to extract tiles
tile_count = 0
for y in range(16, img_height, 24):
    for x in range(16, 296, 24):
        tile = img.crop((x, y, x + tile_size, y + tile_size))
        tile.save(f"{output_dir}/tile_{tile_count}.png")
        tile_count += 1

print(f"Sliced {tile_count} tiles into {output_dir}")