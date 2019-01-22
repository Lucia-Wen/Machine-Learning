import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
import matplotlib as pl
import torchvision
import torchvision.transforms as transforms

from unet_model import UNet
GPU = False
LR = 0.01
EPOCH = 10
BATCH_SIZE = 50


def loadtraindata():
    path = "machine learning/clips/0531"
    trainset = torchvision.datasets.ImageFolder(path,
                                                transform=transforms.Compose([
                                                    transforms.Resize(),
                                                    transforms.CenterCrop(),
                                                    transforms.ToTensor()]))
    trainloader = torch.utils.data.DataLoader(trainset, batch_size=1, shuffle=True, num_workers=2)
    return trainloader



unet = UNet(n_channels=3, n_classes=3)
print(unet)

train_data = loadtraindata()
optimizer = torch.optim.Adam(unet.parameters(), lr=LR)   # optimize all cnn parameters
loss_func = nn.CrossEntropyLoss()                       # the target label is not one-hotted

if GPU:
    unet.cuda()



for epoch in range(EPOCH):
    for step, (x, y) in enumerate(train_data):
        
        if GPU:
            x_c = x.cuda()
            y_c = y.cuda()
        
        output = unet(x)
        loss = loss_func(output, y)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        print('loss=%.4f'%loss)

