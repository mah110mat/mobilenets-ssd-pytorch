import numpy as np
import logging
import pathlib
import xml.etree.ElementTree as ET
import cv2
import os
import glob


class YOLODataset:
    def __init__(self, root, transform=None, target_transform=None,
                 keep_difficult=False, label_file=None):
        # self.root = pathlib.Path(root)
        self.root = root
        self.transform = transform
        self.target_transform = target_transform

        image_sets_file = os.path.join(self.root, '*.jpg')
        label_file_name = os.path.join(self.root, label_file)

        self.ids = self._read_image_ids(image_sets_file)
        self.keep_difficult = keep_difficult

        # if the labels file exists, read in the class names
        if os.path.isfile(label_file_name): 
            classes=[]
            classes.append('BACKGROUND')
            with open(label_file_name, 'r') as infile: 
                for line in infile: 
                    classes.append(line.rstrip())
            self.class_names = tuple(classes)
            logging.info("VOC Labels read from file: " + str(self.class_names))
        else: 
            logging.info("No labels file, using default VOC classes.") 
            self.class_names = ('BACKGROUND', 'hand')

        self.class_dict = { class_name: i for i, class_name in enumerate( self.class_names)}

    def __getitem__(self, index):
        #import pdb; pdb.set_trace()

        image_id = self.ids[index]
        boxes, labels, is_difficult = self._get_annotation(image_id)
        if not self.keep_difficult:
            boxes = boxes[is_difficult == 0]
            labels = labels[is_difficult == 0]
        image = self._read_image(image_id)
        if self.transform:
            image, boxes, labels = self.transform(image, boxes, labels)
        if self.target_transform:
            boxes, labels = self.target_transform(boxes, labels)
        return image, boxes, labels

    def get_image(self, index):
        image_id = self.ids[index]
        image = self._read_image(image_id)
        if self.transform:
            image, _ = self.transform(image)
        return image

    def get_annotation(self, index):
        image_id = self.ids[index]
        return image_id, self._get_annotation(image_id)

    def __len__(self):
        return len(self.ids)

    @staticmethod
    def _read_image_ids(image_sets_file):
        ids = []
        image_sets_file = image_sets_file.replace('images', 'labels')
        image_sets_file = image_sets_file.replace('jpg', 'txt')
        for id in glob.glob(image_sets_file):
            id = os.path.basename(id).split('.')[0]
            ids.append(id)
        return ids

    def _get_annotation(self, image_id):

        annotation_file = self.root.replace('images', 'labels') + f"/{image_id}.txt"
        with open(annotation_file, 'r') as fp:
            lines = fp.readlines()
            img = self._read_image(image_id)
            width = img.shape[1]
            height = img.shape[0]

        boxes = []
        labels = []
        is_difficult = []
        for line in lines:
            line = line.strip('\n').split(' ')
            xcenter = float(line[1]) * width
            ycenter = float(line[2]) * height
            bwidth  = float(line[3]) * width * 0.5
            bheight = float(line[4]) * height * 0.5
            x1 = xcenter - bwidth
            x2 = xcenter + bwidth
            y1 = ycenter - bheight
            y2 = ycenter + bheight
            boxes.append([x1, y1, x2, y2])
            labels.append(int(line[0])+1)
            is_difficult.append(0)

        return (np.array(boxes, dtype=np.float32),
                np.array(labels, dtype=np.int64),
                np.array(is_difficult, dtype=np.uint8))

    def _read_image(self, image_id): 
            image_file = self.root + f"/{image_id}.jpg" 
            image = cv2.imread(str(image_file)) 
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB) 
            return image

