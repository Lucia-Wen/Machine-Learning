import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
import matplotlib as pl

from unet_model import UNet
GPU = False
LR = 0.01
EPOCH = 10
BATCH_SIZE = 50


unet = UNet(n_channels=256, n_classes=256)
if GPU:
    unet.cuda()

optimizer = torch.optim.Adam(unet.parameters(), Lr=LR)
loss_func = nn.CrossEntropyLoss()

for epoch in range(EPOCH):
    for step, (x, y) in enumerate():
        if GPU:
            x_c = x.cuda()
            y_c = y.cuda()
        
        output = unet(x_c)
        loss = loss_func(output, y_c)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

