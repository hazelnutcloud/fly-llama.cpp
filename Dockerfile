# Start with an ubuntu base image
FROM ubuntu:22.04 as base

# Update system and install necessary packages
RUN apt update -q && apt install -y ca-certificates wget && \
    wget -qO /cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i /cuda-keyring.deb && apt update -q

# Builder image used to build and compile the llama server
FROM base as builder

# Install build essentials and specific CUDA development tools
RUN apt-get install -y --no-install-recommends \
  git \
  cuda-nvcc-12-2 \
  libcublas-dev-12-2 \
  libcurl4-openssl-dev

# Set the PATH to include the CUDA binaries
ENV PATH=$PATH:/usr/local/cuda/bin

# Clone the repository and build the application
RUN git clone --depth 1 https://github.com/ggerganov/llama.cpp.git /llama.cpp \
  && cd /llama.cpp \
  && make -j$(nproc) LLAMA_CUDA=1 LLAMA_CURL=1 CUDA_DOCKER_ARCH=compute_86 llama-server

# Runtime image that will run the application
FROM base as runtime

WORKDIR /app

# Install runtime-specific CUDA packages, without development headers/libs
RUN apt-get install -y --no-install-recommends \
  cuda-cudart-12-2 \
  libcublas-12-2 \
  libcurl4 \
  libgomp1

# Copy built binary from the builder stage
COPY --from=builder /llama.cpp/llama-server /app/llama-server

# Add and configure the script that will start the application
COPY ./llama-server.sh /app/llama-server.sh
RUN chmod +x /app/llama-server.sh

# Include the CUDA library directory in the LD_LIBRARY_PATH
ENV LD_LIBRARY_PATh=/usr/local/cuda-12.2/lib64:${LD_LIBRARY_PATH}

# Command to run on container start
CMD ["/app/llama-server.sh"]