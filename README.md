# Object Detection using Hough, Ransac and Template Matching
This project was created as part of my bachelor thesis. The goal is to recognize and classify objects in images using the three named methods. In addition to the existing Matlab script files, an application was designed that cannot be uploaded due to the file size.


## Functionality:
First, an image is selected with the odImagePreprocessing module and converted to a gray scale image. Then the odCannyEdge module converts the gray scale image to a binary edge image.

![alt text](https://i.imgur.com/JynmPjP.jpeg)

In the next step, the different algorithms can be used. The first one is the template Matching in the odTemplateMatching module. A template image is needed, which should be identified in the original image.
