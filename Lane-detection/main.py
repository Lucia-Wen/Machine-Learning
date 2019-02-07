import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
import matplotlib as pl
import torchvision
import torchvision.transforms as transforms
import transforms as ext_transforms
from tusimple import tusimple
import torch.utils.data as data
from unet_model import UNet
from args import get_arguments

GPU = False
LR = 0.01
EPOCH = 10
BATCH_SIZE = 50


# def loadtraindata():
#     path = "machine learning/clips/0531"
#     trainset = torchvision.datasets.ImageFolder(path,
#                                                 transform=transforms.Compose([
#                                                     transforms.Resize(),
#                                                     transforms.CenterCrop(),
#                                                     transforms.ToTensor()]))
#     trainloader = torch.utils.data.DataLoader(trainset, batch_size=1, shuffle=True, num_workers=2)
#     return trainloader


args = get_arguments()

def load_dataset(dataset):
    # dataset: "TuSimple"
    image_transform = transforms.Compose(
            [transforms.Resize((args.height, args.width)),
            transforms.ToTensor()])
    label_transform = transforms.Compose(
        [transforms.Resize((args.height, args.width)),
        ext_transforms.PILToLongTensor()])
    train_data = dataset(root_dir="Lane-detection/data",
                        mode = 'train',
                        transform=image_transform,
                        label_transform=label_transform)
    train_loader = data.DataLoader(
        train_data,
        batch_size= args.batch_size,
        shuffle=True,
        num_workers= args.workers)
    
    # Get encoding between pixel valus in label images and RGB colors
    class_encoding = train_data.color_encoding

    # Get number of classes to predict
    num_classes = len(class_encoding)

    # Print information for debugging
    print("Number of classes to predict:", num_classes)
    print("Train dataset size:", len(train_data))
    # print("Validation dataset size:", len(val_data))

    # Get a batch of samples to display
    images, labels = iter(train_loader).next()
    print("Image size:", images.size())
    print("Label size:", labels.size())
    print("Class-color encoding:", class_encoding)

    return train_loader

def train(train_loader, val_loader, class_encoding):
    print("\n Training...\n")
    num_classes = len(class_encoding)
    unet = UNet(n_channels=3, n_classes=3)
    print(unet)
    optimizer = torch.optim.Adam(unet.parameters(), lr=args.learning_rate)   # optimize all cnn parameters
    loss_func = nn.CrossEntropyLoss()                       # the target label is not one-hotted
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()
    print('loss=%.4f'%loss)


