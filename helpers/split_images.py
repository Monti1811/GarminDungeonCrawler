from PIL import Image
import os

strings_weapons = [
    "steel_", 
    "bronze_", 
    "fire_", 
    "ice_", 
    "grass_", 
    "water_",
    "gold_",
    "demon_",
    "blood_",
    "poison_",
    "platinum_",
    "heaven_",
    "hell_",
]

strings_weapons2 = [
    "sword", 
    "staff", 
    "",
    "axe", 
    "lance",
    "greatsword",
    "dagger",
    "bow",
    "spell",
    "",
    "katana",
    "",
    ""
]

strings_armors = [
    "steel_", 
    "bronze_", 
    "fire_", 
    "ice_", 
    "grass_", 
    "water_",
    "gold_",
    "demon_",
    "blood_",
]

strings_armors2 = [
    "helmet", 
    "armor", 
    "gauntlets",
    "leg_armor", 
    "ring1",
    "ring2",
    "",
    "",
    "",
    "",
    "",
    "",
    ""
]

def getName(counter):
    counter -= 1
    if (counter >= 0) and (counter < 168):
        start = strings_weapons[counter // 13]
        end = strings_weapons2[counter % 13]
        print(counter, start, end)
        if end == "":
            return 
        return start + end
    elif (counter > 181) and (counter < 292):
        start = strings_armors[(counter - 182) // 13]
        end = strings_armors2[(counter - 182) % 13]
        print(counter, start, end)
        if end == "":
            return 
        return start + end
    elif counter == 312:
        return "potion_health"
    elif counter == 313:
        return "potion_mana"
    elif counter == 330:
        return "key"
    elif counter == 340:
        return "gold"
    elif counter == 344:
        return "diamond"
    elif counter == 345:
        return "gold_big"
    else:
        return 


def split_image(image_path, output_folder, tile_size=16):
    # Open the image
    image = Image.open(image_path)
    image_width, image_height = image.size

    # Create the output folder if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Initialize the tile counter
    tile_counter = 1

    # Create a xml file to store the names of the tiles
    # in the format <bitmap id="{name}" filename="items/{name}.png" />
    with open(os.path.join(output_folder, "tiles.xml"), "w") as f:
        f.write("<bitmaps>\n")
        f.write("\n")

        # Loop through the image and save each tile
        for y in range(0, image_height, tile_size):
            for x in range(0, image_width, tile_size):
                # Define the box to crop
                box = (x, y, x + tile_size, y + tile_size)
                tile = image.crop(box)
                name = getName(tile_counter)
                if name:
                    tile.save(os.path.join(output_folder, f"{name}.png"))
                    f.write(f'<bitmap id="{name}" filename="items/{name}.png" />\n')
                else:
                    print("Skipping", tile_counter)
                tile_counter += 1

if __name__ == "__main__":
    image_path = "X:\\Code\\garmin\RPG_Assets\\all the icons (beginning).png"  # Replace with the path to your image
    output_folder = "test"  # Replace with your desired output folder
    split_image(image_path, output_folder)