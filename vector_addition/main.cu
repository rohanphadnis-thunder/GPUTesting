#include <cstdlib>
#include <iostream>
#include <cuda_runtime.h>

const size_t N = 64000;
const size_t T = 64;

bool check_cuda(cudaError_t err, const char* call) {
    if (err == cudaSuccess) {
        return true;
    }

    std::cerr << call << " failed: " << cudaGetErrorString(err) << "\n";
    return false;
}


__global__
void vector_add(int* a, int* b, int* result) {
    for (size_t i = (N/T) * threadIdx.x; i < (N/T) * (threadIdx.x + 1); ++i) {
        result[i] = a[i] + b[i];
    }
}


int main() {

    int* a = new int[N];
    int* b = new int[N];
    int* result = new int[N];
    for (size_t i = 0; i < N; ++i ) {
        a[i] = rand() % 40;
        b[i] = rand() % 40;
    }

    int* da = nullptr;
    int* db = nullptr;
    int* dresult = nullptr;

    if (!check_cuda(cudaMalloc(&da, sizeof(int) * N), "cudaMalloc(da)")) return 1;
    if (!check_cuda(cudaMalloc(&db, sizeof(int) * N), "cudaMalloc(db)")) return 1;
    if (!check_cuda(cudaMalloc(&dresult, sizeof(int) * N), "cudaMalloc(dresult)")) return 1;

    if (!check_cuda(cudaMemcpy(da, a, sizeof(int) * N, cudaMemcpyHostToDevice), "cudaMemcpy(da)")) return 1;
    if (!check_cuda(cudaMemcpy(db, b, sizeof(int) * N, cudaMemcpyHostToDevice), "cudaMemcpy(db)")) return 1;

    vector_add<<<1, T>>>(da, db, dresult);
    if (!check_cuda(cudaGetLastError(), "vector_add launch")) return 1;
    if (!check_cuda(cudaDeviceSynchronize(), "cudaDeviceSynchronize")) return 1;

    if (!check_cuda(cudaMemcpy(result, dresult, sizeof(int) * N, cudaMemcpyDeviceToHost), "cudaMemcpy(result)")) return 1;

    if (!check_cuda(cudaFree(da), "cudaFree(da)")) return 1;
    if (!check_cuda(cudaFree(db), "cudaFree(db)")) return 1;
    if (!check_cuda(cudaFree(dresult), "cudaFree(dresult)")) return 1;

    bool correct = true;
    for (size_t i = 0; i < N && correct; ++i) {
        correct = a[i] + b[i] == result[i];
    }
    std::cout << (correct ? "CORRECT\n" : "INCORRECT\n");

    delete []a;
    delete []b;
    delete []result;
    return 0;
}
