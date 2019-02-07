import os
import torch
import numpy as np
import scipy.misc as m
import utils
from collections import OrderedDict
import torch.utils.data as data
import pdb


class tusimple(data.Dataset):
    """cityscapesLoader

    https://www.cityscapes-dataset.com

    Data is derived from CityScapes, and can be downloaded from here:
    https://www.cityscapes-dataset.com/downloads/

    Many Thanks to @fvisin for the loader repo:
    https://github.com/fvisin/dataset_loaders/blob/master/dataset_loaders/images/cityscapes.py
    """
       # Training dataset root folders
    train_folder = "Lane-detection/data/training/gt_image"
    train_lbl_folder = "Lane-detection/data/training/gt_instance_image"

    # Validation dataset root folders
    # val_folder = "Lane-detection/data/val"
    # val_lbl_folder = "Lane-detection/data/val/gtFine"

    # Test dataset root folders
    # test_folder = "Lane-detection/data/test"
    # test_lbl_folder = "Lane-detection/data/test/gtFine"

    # Filters to find the images
    img_extension = '.png'
    lbl_name_filter = 'labelIds'

    # The values associated with the 35 classes
    full_classes = (0, 20, 70, 120, 170)
    # The values above are remapped to the following
    new_classes = (0, 1, 2, 3, 4)

    # Default encoding for pixel value, class name, and class color
    color_encoding = OrderedDict([
            ('unlabeled', (0, 0, 0)),
            ('lane1', (255, 0, 0)),
            ('lane2', (0, 255, 0)),
            ('lane3', (255, 255, 0)),
            ('lane4', (0, 255, 255)),
            ])

 
    def __init__(self, 
                 root_dir,
                 mode='train',
                 transform=None,
                 label_transform=None,
                 loader=utils.pil_loader):
        self.root_dir = root_dir
        self.mode = mode
        self.transform = transform
        self.label_transform = label_transform
        self.loader = loader


        if self.mode.lower() == 'train':
            # Get the training data and labels filepaths
            self.txtFile = self.root_dir + '/training/%s.txt'%mode
            with open(self.txtFile, 'r') as f:
                self.files = f.readlines()

        self.data = []
        self.label = []
        for index in range(0,len(self.files)):
            info = self.files[index].strip().split(' ')
            self.data.append(info[0])
            self.label.append(info[1])

    def __len__(self):
        """__len__"""
        return len(self.files)

    def __getitem__(self, index):
        
        img, label = self.loader(self.data[index], self.label[index])
        
        # Remap class labels
        label = utils.remap(label, self.full_classes, self.new_classes)

        if self.transform is not None:
            img = self.transform(img)

        if self.label_transform is not None:
            label = self.label_transform(label)

        return img, label