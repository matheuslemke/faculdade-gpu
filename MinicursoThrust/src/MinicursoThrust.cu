/*
 ============================================================================
 Name        : MinicursoThrust.cu
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : Compute sum of reciprocals using STL on CPU and Thrust on GPU
 ============================================================================
 */

#include <algorithm>
#include <iostream>
#include <numeric>
#include <vector>
#include <thrust/make_transform_iterator>

#include <thrust/reduce.h>
#include <thrust/device_vector.h>

using namespace std;

struct quadrado {
	__host__ __device__
	float operator()(float x) {
		return x * x;
	}
};

int main(void) {
	thrust::host_vector<int> h_vec(10);

	thrust::generate(h_vec.begin(), h_vec.end(), rand);

	thrust::device_vector<int> d_vec = h_vec;
	thrust::device_vector<int> d_vec_res(10);

	int resultado = thrust::transform_reduce(d_vec.begin(), d_vec.end(),
			quadrado(), 0.0f, thrust::plus());

	cout << sqrtf(resultado) << endl;

	return 0;
}
