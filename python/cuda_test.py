
import torch
print(torch.cuda.is_available()) # must be True
print(torch.cuda.get_device_name(0)) # name of GPU