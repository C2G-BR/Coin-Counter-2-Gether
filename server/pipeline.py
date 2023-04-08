import torch
import numpy as np
from PIL import Image

class Pipeline():
    def __init__(self, device, target_width = 504, target_height = 504):
        self.target_width = target_width
        self.target_height = target_height
        self.device = device

    def image_to_tensor(self, img):
        img = torch.tensor(img).permute(2,0,1)
        return img.to(self.device).float()
    
    def preprocess_image(self, img):
        img = np.array(img.resize((self.target_width, self.target_height), resample=Image.BILINEAR))/255.
        return img

    def pipe(self, image):
        """
        image: PIL.Image --> convert('RGB')
        """
        image = self.preprocess_image(image)
        image = self.image_to_tensor(image)
        return image