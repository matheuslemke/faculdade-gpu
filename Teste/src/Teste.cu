/*
 ============================================================================
 Name        : Teste.cu
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : CUDA compute reciprocals
 ============================================================================
 */

#include <iostream>
#include <numeric>
#include <stdlib.h>

static void CheckCudaErrorAux(const char *, unsigned, const char *,
		cudaError_t);
#define CUDA_CHECK_RETURN(value) CheckCudaErrorAux(__FILE__,__LINE__, #value, value)

/**
 * CUDA kernel that computes reciprocal values for a given vector
 */
__global__ void reciprocalKernel(float *data, unsigned vectorSize) {
	unsigned idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < vectorSize)
		data[idx] = 1.0 / data[idx];
}

/**
 * Host function that copies the data and launches the work on GPU
 */
float *gpuReciprocal(float *data, unsigned size) {
	float *rc = new float[size];
	float *gpuData;

	CUDA_CHECK_RETURN(cudaMalloc((void ** )&gpuData, sizeof(float) * size));
	CUDA_CHECK_RETURN(
			cudaMemcpy(gpuData, data, sizeof(float) * size,
					cudaMemcpyHostToDevice));

	static const int BLOCK_SIZE = 256;
	const int blockCount = (size + BLOCK_SIZE - 1) / BLOCK_SIZE;
	reciprocalKernel<<<blockCount, BLOCK_SIZE>>>(gpuData, size);

	CUDA_CHECK_RETURN(
			cudaMemcpy(rc, gpuData, sizeof(float) * size,
					cudaMemcpyDeviceToHost));
	CUDA_CHECK_RETURN(cudaFree(gpuData));
	return rc;
}

float *cpuReciprocal(float *data, unsigned size) {
	float *rc = new float[size];
	for (unsigned cnt = 0; cnt < size; ++cnt)
		rc[cnt] = 1.0 / data[cnt];
	return rc;
}

void initialize(float *data, unsigned size) {
	for (unsigned i = 0; i < size; ++i)
		data[i] = .5 * (i + 1);
}

__global__ void addKernel(const int *a, const int *b, int *c) {
	c[blockId.x] = a[blockId.x] + b[blockId.x];
}

int main(void) {
	const int arraySize = 5;
	const int a[arraySize] = { 1, 2, 3, 4, 5 };
	const int b[arraySize] = { 10, 20, 30, 40, 50 };
	const int c[arraySize] = { 0, 0, 0, 0, 0 };

	int *dev_a, *dev_b, *dev_c;

	cudaMalloc((void**) &dev_a, arraySize * sizeof(int));
	cudaMalloc((void**) &dev_b, arraySize * sizeof(int));
	cudaMalloc((void**) &dev_c, arraySize * sizeof(int));

	cudaMemcpy(dev_a, &a, arraySize * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, &b, arraySize * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_c, &c, arraySize * sizeof(int), cudaMemcpyHostToDevice);

	addKernel<<<arraySize, 1>>>(dev_a, dev_b, dev_c);

	cudaMemcpy(&c, dev_c, arraySize * sizeof(int), cudaMemcpyDeviceToHost);

	int var;
	for (var = 0; var < arraySize; ++var) {
		printf("%d ", c[var]);
	}

	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

	return 0;
}

/**
 * Check the return value of the CUDA runtime API call and exit
 * the application if the call has failed.
 */
static void CheckCudaErrorAux(const char *file, unsigned line,
		const char *statement, cudaError_t err) {
	if (err == cudaSuccess)
		return;
	std::cerr << statement << " returned " << cudaGetErrorString(err) << "("
			<< err << ") at " << file << ":" << line << std::endl;
	exit(1);
}

