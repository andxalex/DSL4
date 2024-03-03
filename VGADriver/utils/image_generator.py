from PIL import Image

# Open the image file
image_path = "lada.jpeg"
image = Image.open(image_path)

# Convert the image to black and white
bw_image = image.convert("L")

# Resize the image to 640x480 and transpose it
bw_image_transposed = bw_image.resize((128, 256)).transpose(Image.TRANSPOSE)

bw_image_transposed = bw_image_transposed.rotate(-90, expand=True)

# Convert image pixels to 0 and 1
bw_image_bw = bw_image_transposed.point(lambda x: 0 if x < 128 else 1)

# Save the converted values to a text file
output_file = "car.txt"
with open(output_file, "w") as f:
    width, height = bw_image_bw.size
    for y in range(height):
        for x in range(width):
            pixel_value = bw_image_bw.getpixel((x, y))
            f.write(str(pixel_value))
            f.write("\n")
