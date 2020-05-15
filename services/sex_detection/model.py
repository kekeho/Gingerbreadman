from tensorflow import keras
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, Dense, Dropout, MaxPooling2D, Input, Flatten
from tensorflow.keras.optimizers import RMSprop
from tensorflow.keras.callbacks import TensorBoard
import numpy as np
from PIL import Image
import enum
from glob import glob
from typing import List
import random


class Sex(enum.Enum):
    MALE = enum.auto()
    FEMALE = enum.auto()

def sex_to_categorical(sex: Sex) -> List[int]:
    return [0, 1] if sex == Sex.MALE else [1, 0]


def result_to_sex(csex: np.ndarray) -> Sex:
    return Sex.MALE if np.argmax(csex) == 1 else Sex.FEMALE


def get_images(filename: str) -> (Image.Image, Sex):
    sex = Sex.MALE if filename.split('_')[1] == '0' else Sex.FEMALE
    with open(filename, 'rb') as imgfp:
        image = Image.open(imgfp)
        image = np.asarray(image, dtype='float16')
    
    return image, sex
            



class SexDetection():    
    def __init__(self):
        self.model = self._model()

    def _model(self):
        model = Sequential()
        model.add(Conv2D(32, (2, 2), input_shape=(200, 200, 3), activation='relu'))
        model.add(MaxPooling2D())
        model.add(Conv2D(24, (2, 2), input_shape=(200, 200, 3), activation='relu'))
        model.add(MaxPooling2D())
        model.add(Conv2D(16, (2, 2), activation='relu'))
        model.add(MaxPooling2D())
        model.add(Conv2D(8, (2, 2), activation='relu'))
        model.add(MaxPooling2D())
        model.add(Conv2D(4, (2, 2), activation='relu'))
        model.add(MaxPooling2D())
        model.add(Conv2D(2, (2, 2), activation='relu'))
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
    
    def load_datasets(self):
        train_x = []
        train_y = []
        for filename in glob('./UTKFace/*'):
            x, y = get_images(filename)
            train_x.append(x)
            train_y.append(sex_to_categorical(y))

        # Shuffle
        randseed = random.randint(0, 99999)
        random.seed(randseed)
        random.shuffle(train_x)
        random.seed(randseed)
        random.shuffle(train_y)
        
        self.train_x = np.asarray(train_x)
        self.train_y = np.asarray(train_y)
    
    def train(self):
        self.model.fit(x=self.train_x, y=self.train_y, validation_split=0.2, epochs=30, callbacks=[TensorBoard()])
        self.model.save('sex_detection.h5')
