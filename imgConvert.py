import numpy as np
from PIL import Image as img


def blackBox(imagePath):
    photo = img.open(imagePath)
    name = photo.filename
    width,height = photo.size

    photo = photo.convert("L")

    
    y = np.asarray(photo.getdata(),dtype=np.float64).reshape((photo.size[1],photo.size[0]))
    y = np.asarray(y,dtype=np.uint8)
    
    z = y.reshape(1,y.size)
    
    widthFixerAndPrinter(z[0],name,width,height)



def widthFixerAndPrinter(matrix,filename,width,height):
    output = ''

    if filename[-4:] == 'jpeg':
        filename = filename[:-5]
    else:
        filename = filename[:-4]

    size = str(width).zfill(5)+str(height).zfill(5)
    
    for i in matrix:
        output += str(i).zfill(3)

    with open(filename+"_matrix.txt","w") as text_file:
        print(output, file=text_file)
        
    with open(filename+"_size.txt","w") as text_file:
        print(size,file=text_file)

    

blackBox("images/pngMadeMini.png")
