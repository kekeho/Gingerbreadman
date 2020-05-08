import keras 
from keras.models import Sequential
from keras.layers import Conv2D, Dense, Dropout, MaxPooling2D, Input, Flatten
from keras.optimizers import RMSprop
from keras.callbacks import TensorBoard
import keras
import numpy as np
from PIL import Image
import enum
from glob import glob
from typing import List


class Sex(enum.Enum):
    MALE = 0
    FEMALE = 1
    UNKNOWN = 2


def get_images(annotation_filename: str) -> (List[Image.Image], List[Sex]):
    with open(annotation_filename, 'r') as f:
        x = []
        y = []
        for line in f.readlines()[1:]:
            col = line.split('	')
            directory = col[0]
            filename = col[1]
            image_filenames = glob(f'./adiencedb/faces/{directory}/*.{filename}')
            sex = Sex.MALE if col[4] == 'm' else Sex.FEMALE if col[4] == 'f' else Sex.UNKNOWN

            if sex == Sex.UNKNOWN:
                continue

            for image_filename in image_filenames:
                with open(image_filename, 'rb') as imgfp:
                    image = Image.open(imgfp)
                    image = image.resize((256, 256))
                    image = np.asarray(image, dtype='float16')
                    x.append(image)
                    y.append(sex)
    
    return x, y
            



class SexDetection():    
    def __init__(self):
        self.model = self._model()
        self.train_x, self.train_y = self._datasets()


    def _model(self):
        model = Sequential()
        model.add(Conv2D(32, (3, 3), input_shape=(256, 256, 3), activation='relu'))
        model.add(MaxPooling2D())
        model.add(Conv2D(16, (3, 3), activation='relu'))
        model.add(MaxPooling2D())
        model.add(Dropout(0.25))
        model.add(Conv2D(6, (3, 3), activation='relu'))
        model.add(MaxPooling2D())
        model.add(Dropout(0.25))
        model.add(Conv2D(2, (3, 3), activation='relu'))
        model.add(MaxPooling2D())
        model.add(Flatten())
        model.add(Dense(64, activation='relu'))
        model.add(Dropout(0.5))
        model.add(Dense(12, activation='relu'))
        model.add(Dropout(0.5))
        model.add(Dense(4, activation='relu'))
        model.add(Dense(2, activation='sigmoid'))

        model.compile(optimizer=RMSprop(), loss='binary_crossentropy', metrics=['binary_accuracy'])
        return model
    
    def _datasets(self):
        train_files = [ f'./adiencedb/fold_{x}_data.txt' for x in range(0, 4+1)]

        train_x = []
        train_y = []
        for filename in train_files:
            x, y = get_images(filename)
            train_x.append(x)
            train_y.append(y)
        
        return train_x, train_y
    
    def train(self):
        self.model.fit(x=self.train_x, y=self.train_y, validation_split=0.2, callbacks=[TensorBoard()])
        self.model.save('adiencedb.h5')




g = SexDetection()
g.train()


