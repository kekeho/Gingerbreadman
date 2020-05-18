# Copyright (C) 2020 Hiroki Takemura (kekeho)
# 
# This file is part of Gingerbreadman.
# 
# Gingerbreadman is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Gingerbreadman is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Gingerbreadman.  If not, see <http://www.gnu.org/licenses/>.

from tensorflow import keras
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Conv2D, Dense, Dropout, MaxPooling2D, Input, Flatten
from tensorflow.keras.applications import Xception
from tensorflow.keras.optimizers import RMSprop
from tensorflow.keras.callbacks import TensorBoard
import numpy as np
from PIL import Image
import enum
from glob import glob
from typing import List
import random
import gc


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
        self.base_model = Xception(
            include_top=False,
            weights='imagenet',
            input_shape=(200, 200, 3)
        )
        self.model = self._model()

    def _model(self):
        x = self.base_model.output
        x = MaxPooling2D()(x)
        x = Conv2D(256, (3, 3))(x)
        x = Flatten()(x)
        x = Dense(64, activation='relu')(x)
        x = Dropout(0.5)(x)
        x = Dense(16, activation='relu')(x)
        x = Dropout(0.5)(x)
        x = Dense(4, activation='relu')(x)
        y = Dense(2, activation='sigmoid')(x)

        model = Model(inputs=self.base_model.input, outputs=y)

        # Freeze
        for layer in model.layers[:108]:
            if layer.name.startswith('batch_normalization'):
                layer.trainable = True
                continue
            
            if layer.name.endswith('bn'):
                layer.trainable = True
                continue

            layer.trainable = False
        
        for layer in model.layers[108:]:
            layer.trainable = True

        model.compile(optimizer=RMSprop(), loss='binary_crossentropy', metrics=['binary_accuracy'])
        return model
    
    
    def train(self):
        epoch = 30
        files = glob('./UTKFace/*')
        random.shuffle(files)


        for ep in range(epoch):
            train_x = []
            train_y = []
            index = 0
            print('ep:',ep)
            print(train_x, train_y, index)
            while index < len(files):
                x, y = get_images(files[index])
                train_x.append(x)
                train_y.append(sex_to_categorical(y))
                if (index > 0 and (index % 3000 == 0)) or (index == len(files)-1):
                    train_x = np.array(train_x)
                    train_y = np.array(train_y)
                    print(train_x.shape)
                    self.model.fit(x=train_x, y=train_y, validation_split=0.2, callbacks=[TensorBoard()])
                    train_x = []
                    train_y = []
                    index += 1
                index += 1
            del train_x
            del train_y
            gc.collect()

        self.model.save('sex_prediction.h5')
