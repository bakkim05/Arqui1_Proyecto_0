import numpy as np
from PIL import Image as img

photo = img.open("images/nature_min.jpg")
name = photo.filename
width,height = photo.size

photo = photo.convert("L")
photo.show()


y = np.asarray(photo.getdata(),dtype=np.float64).reshape((photo.size[1],photo.size[0]))
y = np.asarray(y,dtype=np.uint8)

y = np.pad(y,1,constant_values=0)

z = y.reshape(1,y.size)

if name[-4:] == 'jpeg':
    name = name[:-5]
else:
    name = name[:-4]

size_file = name+"_size.txt"

matrix_file = name+"_matrix.txt" 

