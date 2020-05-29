from PIL import Image as img
import numpy as np

size_file = open("images/nature_min_size.txt","r")
size = size_file.read()
size = size[:-1]
width = int(size[:5])
height = int(size[5:])
width -= 2
height -= 2

sharpened_file = open("images/sharpened.txt","r")
sharpened = sharpened_file.read().split(' ')
sharpened = sharpened[0:-1]
#sharpened = sharpened.insert(0,sharpened.pop())
##last = sharpened[-1]
##sharpened.insert(0,last)
sharpened = np.array(sharpened)
sharpened = sharpened.astype(np.int)
sharpened = np.reshape(sharpened, (height,width))

image = img.fromarray(np.uint8(sharpened),'L')
image.show()


osharpened_file = open("images/oversharpened.txt","r")
osharpened = osharpened_file.read().split(' ')
osharpened = osharpened[0:-1]
##last = sharpened[-1]
##sharpened.insert(0,last)
osharpened = np.array(sharpened)
osharpened = osharpened.astype(np.int)
osharpened = np.reshape(osharpened, (height,width))

image2 = img.fromarray(np.uint8(osharpened),'L')
image2.show()
