import numpy as np
from PIL import Image as img







def blackBox(imagePath):
    photo = img.open(imagePath)
    photo = photo.convert("L")
    print(photo)
    y = np.asarray(photo.getdata(),dtype=np.float64).reshape((photo.size[1],photo.size[0]))
    y = np.asarray(y,dtype=np.uint8) #if values still in range 0-255! 

    z = y.reshape(1,y.size)

    np.savetxt("data.txt",z,delimiter='00',fmt='%d')
