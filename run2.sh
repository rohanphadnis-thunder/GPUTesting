ls /usr/local/cuda-13.3/bin

cd /
sudo find -name "nvcc"

/usr/local/cuda-13.3/bin/nvcc GPUTesting/vector_addition/main.cu
./a.out
