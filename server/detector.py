import torch
import torchvision
import numpy as np
import torchvision.transforms as transform

from torchvision.ops import nms
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.utils import draw_bounding_boxes
from os.path import join
from datetime import datetime

from pipeline import Pipeline

class CoinDetector():
    def __init__(self, model_path, target2label, threshold = None):
        
        self.num_classes = len(target2label)
        self.target2label = target2label
        self.threshold = threshold

        # read model
        self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        print(self.device)
        self.model = torchvision.models.detection.fasterrcnn_mobilenet_v3_large_fpn(pretrained=False)
        in_features = self.model.roi_heads.box_predictor.cls_score.in_features
        self.model.roi_heads.box_predictor = FastRCNNPredictor(in_features, self.num_classes)
        self.model.load_state_dict(torch.load(model_path, map_location=self.device))
        self.model.to(self.device)

        # create pipeline
        self.transformer_to_PIL = transform.ToPILImage()
        self.pipeline = Pipeline(self.device)

        print('Finished initializing CoinDetector')

    def calculate_coin_value(labels, confs, bboxes, threshold = None):
        coin_value = 0
        if threshold is None:
            threshold = 0
        for ix, label in reversed(list(enumerate(labels))):
            if confs[ix] > threshold:
                coin_value += label
            else:
                del labels[ix]
                del confs[ix]
                del bboxes[ix]
        return labels, confs, bboxes, coin_value

    def decode_output(self, output, normalize_bbs = True, size = None):
        'convert tensors to numpy arrays'
        bbs = output['boxes'].cpu().detach().numpy().astype(np.uint16)
        labels = np.array([self.target2label[i] for i in output['labels'].cpu().detach().numpy()])
        confs = output['scores'].cpu().detach().numpy()
        ixs = nms(torch.tensor(bbs.astype(np.float32)), torch.tensor(confs), 0.05)
        bbs, confs, labels = [tensor[ixs] for tensor in [bbs, confs, labels]]

        # converts bounding boxes as type int to float
        if normalize_bbs and size is not None:
            bbs = bbs.astype(float)
            not_scaled_bbs = bbs.copy()
            width, height = size
            if bbs.ndim == 1:
                bbs[[0, 2]] = bbs[[0, 2]] / width
                bbs[[1, 3]] = bbs[[1, 3]] / height
            else:
                bbs[:, [0, 2]] = bbs[:, [0, 2]] / width
                bbs[:, [1, 3]] = bbs[:, [1, 3]] / height

        if len(ixs) == 1:
            bbs, confs, labels = [np.array([tensor]) for tensor in [bbs, confs, labels]]
        return bbs.tolist(), confs.tolist(), labels.tolist(), not_scaled_bbs

    def predict(self, img):
        img = self.pipeline.pipe(img)
        width, height = img.shape[1:]
        imgs = [img]

        self.model.eval()
        print("Start predictions")
        outputs = self.model(imgs)
        for output in outputs:
            bboxes, confs, labels, not_scaled_bbs = self.decode_output(output, size=(width, height))
            labels, confs, bboxes, coin_value = CoinDetector.calculate_coin_value(labels, confs, bboxes, threshold = self.threshold)
            info = [f'{l}@{c:.2f}' for l,c in zip(labels, confs)]

            # Preview/save prediction
            try:
                img = draw_bounding_boxes((img*255).to(dtype=torch.uint8), boxes=torch.tensor(not_scaled_bbs), labels=info, width=5)
                img = torchvision.transforms.ToPILImage()(img)
                img.save(join('images', f"img_{datetime.now().strftime('%m-%d-%Y_%H-%M-%S')}.png"))
            except:
                print("No box drawn")

            return coin_value, bboxes, info