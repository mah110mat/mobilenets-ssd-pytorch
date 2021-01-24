#python train_ssd_VOC.py \
#	--datasets ./data/VOCdevkit/VOC2007/ \
#	--validation_dataset ./data/VOCdevkit/test/VOC2007/ \
python train_ssd_hand.py \
	--datasets ../dataset/hand/images/train/ \
	--validation_dataset ./dataset/hand/images/valid/ \
	--use_cuda True \
	--net mb2-ssd-lite \
	--pretrained_ssd models/mb2-ssd-lite-net.pth \
	--scheduler cosine --lr 0.01 --batch_size 32 --num_epochs 2000

#python train_ssd_ego.py \
#	--datasets /proj2/BNN/work/20210122/egohands/images/train/ \
#	--validation_dataset /proj2/BNN/work/20210122/egohands/images/test/ \
#	--use_cuda True \
#	--net mb2-ssd-lite \
#	--pretrained_ssd models/mb2-ssd-lite-net.pth \
#	--scheduler cosine --lr 0.01 --t_max 300 --batch_size 16 --num_epochs 300

