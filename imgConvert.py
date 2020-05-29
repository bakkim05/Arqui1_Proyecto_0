import numpy as np
from PIL import Image as img
import os
import time


def blackBox(imagePath):
        photo = img.open(imagePath)
        name = photo.filename
        width,height = photo.size

        photo = photo.convert("L")
        photo.show()

        y = np.asarray(photo.getdata(),dtype=np.float64).reshape((photo.size[1],photo.size[0]))
        y = np.asarray(y,dtype=np.uint8)
        y = np.pad(y, 1, constant_values = 0)
        
        z = y.reshape(1,y.size)

        if name[-4:] == 'jpeg':
        name = name[:-5]
        else:
        name = name[:-4]

        size_file = name+"_size.txt"

        matrix_file = name+"_matrix.txt" 


        widthFixerAndPrinter(z[0],size_file,matrix_file,width,height)

        #BASH

        os.system("./main")
        time.sleep(5)

        text2img(size_file)

        #print(file_name)

        #text2img()

        #add buffers

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


def text2img (size_file):
        size_file = open(size_file,"r")
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




blackBox(str(input("insert path of image you want to sharpen and oversharpen: ")))
