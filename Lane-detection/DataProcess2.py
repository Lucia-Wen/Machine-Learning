import os
from PIL import Image
from torch.utils.data import DataLoader, Dataset


class TusimpleDataset(Dataset):
    def __init__(self, data_dir, transform):
        self.filenames = os.listdir(data_dir)
        self.filenames = [os.path.join(data_dir, f) for f in self.filenames]

        self.labels = [int(filename.split('/')[-1][0]) for filename in self.filenames]
        self.transform = transform

    def __len__(self):
        return len(self.filenames)

    def __getitem__(self, idx):
        image = Image.open(self.filenames[idx])
        image = self.transform(image)
        return image, self.labels[idx]

