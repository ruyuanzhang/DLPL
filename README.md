#Deep Learning and Perceptual Learning

This project is developed by Ruyuan Zhang and Lingxiao Yang. We aim to utilize features learned by deep learning model in complex object recognition task to approxiamte human low-level perceptual learning performance.

The package contains three main files:

###staircase.m

The utility function to create,update and computer adaptive staircase program. This file should not be changed.

###NoiseGabor2.m

The codes for a typical perceptual learning task. This is a reference file, should not be changed.

###DLPL.m

Main function of deep learning and perceptual learning (DLPL). This script includes one formal perceptual learning task (320 trials). In the middle this script, the section is illustrated that variable **imgtmp** is the image to provide to deep nextwork. The variable **choice** should 1 or 2, indicating the choice by deep network counterclockwise rotation and clockwise rotation.


Contact:
Ruyuan Zhang, ruyuanzhang@gmail.com

    