import cv2
import json
import numpy as np
 
file=open(r'Lane-detection\data\label_data_0531.json','r')
image_num=0
for line in file.readlines():
    data=json.loads(line)
    image=cv2.imread(data['raw_file'])
    binaryimage=np.zeros((image.shape[0],image.shape[1],1),np.uint8)
    instanceimage=binaryimage.copy()
    arr_width=data['lanes']
    arr_height=data['h_samples']
    width_num=len(arr_width)
    height_num=len(arr_height)
    for i in range(height_num):
        lane_hist=20
        for j in range(width_num):
            if arr_width[j][i-1]>0 and arr_width[j][i]>0:
                binaryimage[int(arr_height[i]),int(arr_width[j][i])]=255
                instanceimage[int(arr_height[i]),int(arr_width[j][i])]=lane_hist
                if i>0:
                    cv2.line(binaryimage, (int(arr_width[j][i-1]),int(arr_height[i-1])), (int(arr_width[j][i]),int(arr_height[i])), 255, 10)
                    cv2.line(instanceimage,(int(arr_width[j][i-1]),int(arr_height[i-1])), (int(arr_width[j][i]),int(arr_height[i])), lane_hist, 10)
            lane_hist+=50
    # string1="Lane-detection/gt_image_binary/"+str(image_num)+".png"
    string1="Lane-detection/data/"+str(image_num)+".png"
    string2="Lane-detection/gt_image_instance/"+str(image_num)+".png"
    string3="Lane/image/"+str(image_num)+".png"
    cv2.imwrite(string1,binaryimage)
    cv2.imwrite(string2,instanceimage)
    cv2.imwrite(string3,image)
    
    image_num=image_num+1
file.close()

