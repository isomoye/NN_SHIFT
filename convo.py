import numpy as np
from PIL import Image



def convolution2d(image, kernel, bias):
    m, n = kernel.shape
    if (m == n):
        y, x = image.shape
        y = y - m + 1
        x = x - m + 1
        new_image = np.zeros((y,x))
        for i in range(y):
            for j in range(x):
                new_image[i][j] = np.sum(image[i:i+m, j:j+m]*kernel) + bias
    return new_image

basewidth = 28
img = Image.open('sample_image.png')
wpercent = (basewidth / float(img.size[0]))
hsize = int((float(img.size[1]) * float(wpercent)))
img = img.resize((basewidth, basewidth))

convolution_kernel = np.array([[0, 1, 0], 
                               [1, 1.5, 1], 
                               [0, 1, 0]])
  
images = np.array(img)
print(images.shape)
print(convolution_kernel.shape)
convo = convolution2d(images,convolution_kernel,0)
# convo = np.convolve(convolution_kernel,images)

print(convo)