# fly-llama.cpp

Deploy a llama.cpp server on fly.io. Uses the most minimal dependencies possible to create a small image.

## Usage

```sh
fly launch --no-deploy
fly vol create models -s 10 --vm-gpu-kind a10 --region ord
fly deploy
```

## Configuration

The provided Dockerfile is configured to use the `a10` GPU kind. To use a different GPU, follow these steps:

1. Update the `CUDA_DOCKER_ARCH` variable in the build step to an appropriate value for the desired GPU.
   A list of arch values can be found [here](https://developer.nvidia.com/cuda-gpus). e.g. put `CUDA_DOCKER_ARCH=compute_86` for compute capability 8.6.
2. Update the `--vm-gpu-kind` flag in the `fly vol create` command to the desired GPU kind. e.g. put `--vm-gpu-kind a100` for an A100 GPU.
3. Update the vm.gpu_kind in the fly.toml file to the desired GPU kind. e.g. put `gpu_kind = "a100"` for an A100 GPU.
