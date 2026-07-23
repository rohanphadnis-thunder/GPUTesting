#include <iostream>
#include <cuda.h>

const size_t N = 16000;
const size_t T = 64;


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

    int* da; int* db; int* dresult;
    cudaMalloc(&da, sizeof(int) * N);
    cudaMalloc(&db, sizeof(int) * N);
    cudaMalloc(&dresult, sizeof(int) * N);

    cudaMemcpy(da, a, sizeof(int) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(db, b, sizeof(int) * N, cudaMemcpyHostToDevice);

    vector_add<<<1, T>>>(da, db, dresult);

    cudaDeviceSynchronize();

    cudaMemcpy(result, dresult, sizeof(int) * N, cudaMemcpyDeviceToHost);
    cudaFree(da);
    cudaFree(db);
    cudaFree(dresult);

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
