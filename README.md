# fly-llama.cpp

Deploy a [llama.cpp](https://github.com/ggerganov/llama.cpp/tree/master/examples/server) server on [fly.io](https://fly.io).

Uses the most minimal dependencies possible to create a small image. Downloads model files on initial boot and caches them in a volume for fast subsequent cold starts.

## Usage

```sh
fly launch --no-deploy
fly vol create models -s 10 --vm-gpu-kind a10 --region ord
fly secrets set API_KEY=<your-api-key>
fly deploy
```

## Configuration

### GPU

The provided Dockerfile is configured to use the `a10` GPU kind. To use a different GPU:

1. Update the `CUDA_DOCKER_ARCH` variable in the build step to an appropriate value for the desired GPU.
   A list of arch values can be found [here](https://developer.nvidia.com/cuda-gpus). e.g. put `CUDA_DOCKER_ARCH=compute_86` for compute capability 8.6.
2. Update the `--vm-gpu-kind` flag in the `fly vol create` command to the desired GPU kind. e.g. put `--vm-gpu-kind a100` for an A100 GPU.
3. Update the vm.gpu_kind in the fly.toml file to the desired GPU kind. e.g. put `gpu_kind = "a100"` for an A100 GPU.

### Model

This example uses the `phi-3-mini-4k-instruct` model by default. To use a different model:

1. update the `MODEL_URL` and `MODEL_FILE` env variables in the fly.toml file to your desired model. The file will be downloaded as `/models/$MODEL_FILE` on next deploy.
2. To delete any existing model files, use `fly ssh console` to connect to your machine and run `rm /models/<model_file>`.

### API Key

This example sets the `--api-key` flag on the server start command to guard against unauthorized access. To set the API key:

```sh
fly secrets set API_KEY=<your-api-key>
```

The app will use the new API key on the next deploy.