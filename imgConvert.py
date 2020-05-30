import numpy as np
from PIL import Image as img
import os
import time


def blackBox(imagePath):
    photo = img.open(imagePath)
    name = photo.filename
    width,height = photo.size

    photo = photo.convert("L")

    
    y = np.asarray(photo.getdata(),dtype=np.float64).reshape((photo.size[1],photo.size[0]))
    y = np.asarray(y,dtype=np.uint8)
    y = np.pad(y, 1, constant_values = 0)

    width += 2
    height += 2
    
    z = y.reshape(1,y.size)

    if name[-4:] == 'jpeg':
        name = name[:-5]
    else:
        name = name[:-4]

    size_file = name+"_size.txt"

    matrix_file = name+"_matrix.txt" 


    widthFixerAndPrinter(z[0],size_file,matrix_file,width,height)



def widthFixerAndPrinter(matrix, size_file, matrix_file, width, height):
    output = ''

    size = str(width).zfill(5)+str(height).zfill(5)
    
    for i in matrix:
        output += str(i).zfill(3)

    with open(matrix_file,"w") as text_file:
        print(output, file=text_file)

    filename = text_file
        
    with open(size_file,"w") as text_file:
        print(size,file=text_file)





blackBox(str(input("insert path of image you want to sharpen and oversharpen: ")))