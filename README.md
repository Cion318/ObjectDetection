# Object Detection using Hough, Ransac and Template Matching
This project was created as part of my bachelor thesis. The goal is to recognize and classify objects in images using the three named methods. In addition to the existing Matlab script files, an application was designed that cannot be uploaded due to the file size.


## Image Preprocessing
First, an image is selected with the odImagePreprocessing module and converted to a gray scale image. Then the odCannyEdge module converts the gray scale image to a binary edge image.

![alt text](https://i.imgur.com/JynmPjP.jpeg)

## Template Matching
In the next step, the different algorithms can be used. The first one is the template Matching in the odTemplateMatching module. A template image is needed, which should be identified in the original image.

![alt text](https://imgur.com/DLQgf54.jpg)

## Hough-Transformation
The next one is the Hough-Transformation for line and circle detection. Those are implemented in the odHoughLines and odHoughCircles modules. The following paramaters were used to achieve the results below.
#### Parameters for Hough-Lines Transformation
| Peaks | Threshold | Gap | min. Linelength |
|-------|-----------|-----|-----------------|
|   30  |    0.2    |  15 |        20       |

#### Parameters for Hough-Circles Transformation
|min. Radius|max. Radius|
|-----------|-----------|
|     10    |     50    |

![alt text](https://imgur.com/EHvxQVv.jpg)

## Ransac-Algorithm
The last one is the Ransac-Algorithm for line and circle detection. Those are implemented in the odRansacLines and odRansacCircles modules. The following paramaters were used to achieve the results below.
#### Parameters for Hough-Lines Transformation
| Runs | Iterations | Tolerance | Ratio | Gap |
|------|------------|-----------|-------|-----|
|  30  |    1000    |     1     |  0.03 |  5  |

#### Parameters for Hough-Circles Transformation
| Runs | Iterations | Tolerance |
|------|------------|-----------|
|  20  |    1000    |    1.5    |

![alt text](https://imgur.com/LhLUrHW.jpg)
