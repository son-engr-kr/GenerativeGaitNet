# Generative GaitNet (Simple Version)

The updated version is available in https://github.com/namjohn10/BidirectionalGaitNet.

## Abstract 

Understanding the relation between anatomy and gait is key to successful predictive gait simulation. In this paper, we present Generative GaitNet, which is a novel network architecture based on deep reinforcement learning for controlling a comprehensive, full body, musculoskeletal model with 304 Hill-type musculotendons. The Generative GaitNet is a pre-trained, integrated system of artificial neural networks learned in a 618-dimensional continuous domain of anatomy conditions (e.g., mass distribution, body proportion, bone deformity, and muscle deficits) and gait conditions (e.g., stride and cadence). The pre-trained GaitNet takes anatomy and gait conditions as input and generates a series of gait cycles appropriate to the conditions through physics-based simulation. We will demonstrate the efficacy and expressive power of Generative GaitNet to generate a variety of healthy and pathological human gaits in real-time physics-based simulation.

## Video (Youtube)
[![GenerativeGaitNet](https://img.youtube.com/vi/ITkOxtWvNGE/0.jpg)](https://youtu.be/ITkOxtWvNGE)


## Publications

https://mrl.snu.ac.kr/research/ProjectGaitNet/paper.pdf

Jungnam Park, Sehee Min, Phil Sik Chang, Jaedong Lee, Moon Seok Park, and Jehee Lee 
Generative GaitNet, SIGGRAPH 2022 Conference Proceedings. 

## Installation 

We checked code works in Python 3.6, ray(rllib) 1.8.0 and Cluster Server (64 CPUs (128 threads) and 1 GPU (RTX 3090) per node)

### Install Library Automatically

```bash
cd {downloaded folder}/
./install.sh
```
`root\pkgsrc\dart\examples\deprecated_examples\glut_human_joint_limits\CMakeLists.txt`
```bash
if(DART_IN_SOURCE_BUILD)
    dart_build_example_in_source(${example_name}
      LINK_LIBRARIES ${required_libraries}
      COMPILE_FEATURES cxx_std_14
    )
  #endif() ->  delete this line
  return()
endif()
```

```bash
python3.6 -m venv .venv
source .venv/bin/activate
```
### Compile
```bash
cd {downloaded folder}/
./pc_build.sh
cd build
make -j${proc}
```

cuda version: 12.1 (maybe)
```
pip install --upgrade pip
pip install ray[rllib]==1.8.0
pip uninstall gym -y
pip install gym==0.21.0
pip install IPython

cd path/to/temp
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-5
nvcc --version

//pip install torch torchvision torchaudio
pip install torch==1.7.1+cu110 torchvision==0.8.2+cu110 -f https://download.pytorch.org/whl/torch_stable.html

```


## Rendering

To run without policy 

```bash
cd {downloaded folder}/build
./imgui_render/imgui_render ../data/metadata.txt
```
or the trained policy.

```bash
cd {downloaded folder}/build
./imgui_render/imgui_render {network_path}
```

To run with trained 4 policies (to lower body), 

```bash
cd {downloaded folder}/build
./imgui_render/imgui_render ../data/trained_nn/Skeleton ../data/trained_nn/Ankle ../data/trained_nn/Hip ../data/trained_nn/Merge
```

And check the edge connection file, ./data/cascading_map.txt (The right number is descendant policy in the graphs)

```bash
1 0
2 0
3 0
3 1
3 2
```

## Learning

### Parameter Setting

Set adjustable parameters in {downloaded folder}/data/metadata.txt. 
The group flag groups muscles containing the given name.

To set muscle length,
```bash
muscle_param
group(or not use) {Left Muscle1 Name} {min ratio} {max ratio}
group(or not use) {Right Muscle1 Name} {min ratio} {max ratio}
group(or not use) {Left Muscle2 Name} {min ratio} {max ratio}
group(or not use) {Right Muscle2 Name} {min ratio} {max ratio}
...
muscle_end
```

To set muscle force,
```bash
muscle_param
group(or not use) {Left Muscle1 Name} {min ratio} {max ratio}
group(or not use) {Right Muscle1 Name} {min ratio} {max ratio}
group(or not use) {Left Muscle2 Name} {min ratio} {max ratio}
group(or not use) {Right Muscle2 Name} {min ratio} {max ratio}
...
muscle_end
```

To set body proportion force,
```bash
muscle_param
global {min ratio} {max ratio}
Head {min ratio} {max ratio}
{Left Body Name} {min ratio} {max ratio}
{Right Body Name} {min ratio} {max ratio}
...
muscle_end
```

### Training

Training is executed based on the metadata setting. 

Training a single policy (Cluster setting)

```bash
cd {downloaded folder}/python
python3 ray_train.py --config=ppo_medium_node 
```

Cascading and Subsumption learning

```bash
cd {downloaded folder}/python
python3 ray_train.py --config=ppo_medium_node --cascading_nn={previous network paths}
```

pc test
```bash
cd {downloaded folder}/python
python3 ray_train.py --config=ppo_mini
```

