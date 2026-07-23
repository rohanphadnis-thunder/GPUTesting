ls /usr/local/cuda-13.3/bin

cd /
sudo find -n "nvcc"

/usr/local/cuda-13.3/bin/nvcc GPUTesting/vector_addition/main.cu
./a.out
