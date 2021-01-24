# Start FROM Nvidia PyTorch image https://ngc.nvidia.com/catalog/containers/nvidia:pytorch
FROM nvcr.io/nvidia/pytorch:20.12-py3

ENV DEBIAN_FRONTEND noninteractive
# Install linux packages
RUN apt-get update && apt-get install -y screen libgl1-mesa-glx

# Install python dependencies
RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN pip install gsutil

## Create working directory
#RUN mkdir -p /usr/src/app
#WORKDIR /usr/src/app
#
## Copy contents
#COPY . /usr/src/app
#
## Copy weights
##RUN python3 -c "from models import *; \
##attempt_download('weights/yolov3.pt'); \
##attempt_download('weights/yolov3-spp.pt'); \
##attempt_download('weights/yolov3-tiny.pt')"

# user settings
ENV TZ=Asia/Tokyo
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake build-essential curl gdb git wget byobu fdclone 
RUN apt-get install -y --no-install-recommends locales
ARG user_name=matsumoto
ARG user_id=1000
ARG group_name=matsumoto
ARG group_id=1000

RUN groupadd -g ${group_id} ${group_name}
RUN useradd -u ${user_id} -g ${group_id} -d /home/${user_name} --create-home --shell /bin/bash ${user_name}
RUN echo "${user_name} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R ${user_name}:${group_name} /home/${user_name}

RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
#ENV TZ=Asia/Tokyo

USER matsumoto
VOLUME /home/matsumoto
ENV HOME /home/matsumoto


# Return to project directory and open a terminal
WORKDIR /work

# ---------------------------------------------------  Extras Below  ---------------------------------------------------

# Build and Push
# t=ultralytics/yolov3:latest && sudo docker build -t $t . && sudo docker push $t
# for v in {300..303}; do t=ultralytics/coco:v$v && sudo docker build -t $t . && sudo docker push $t; done

# Pull and Run
# t=ultralytics/yolov3:latest && sudo docker pull $t && sudo docker run -it --ipc=host $t

# Pull and Run with local directory access
# t=ultralytics/yolov3:latest && sudo docker pull $t && sudo docker run -it --ipc=host --gpus all -v "$(pwd)"/coco:/usr/src/coco $t

# Kill all
# sudo docker kill $(sudo docker ps -q)

# Kill all image-based
# sudo docker kill $(sudo docker ps -a -q --filter ancestor=ultralytics/yolov3:latest)

# Bash into running container
# sudo docker container exec -it ba65811811ab bash

# Bash into stopped container
# sudo docker commit 092b16b25c5b usr/resume && sudo docker run -it --gpus all --ipc=host -v "$(pwd)"/coco:/usr/src/coco --entrypoint=sh usr/resume

# Send weights to GCP
# python -c "from utils.general import *; strip_optimizer('runs/train/exp0_*/weights/best.pt', 'tmp.pt')" && gsutil cp tmp.pt gs://*.pt

# Clean up
# docker system prune -a --volumes
