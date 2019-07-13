
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include <math.h>

float * generate_rand_input(int rows, int cols) {
  // ============================================
  // Allocating the matrices based on dimensions rows x cols
  // ============================================
  float * mat = malloc( rows * cols * sizeof(float));

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      mat[i * cols + j] = rand() % 16;
    }
  }

  return mat;
}


float * generate_output(int rows, int cols) {
  // ============================================
  // Allocating the output matrix based on dimensions rows x cols
  // with 0's as initial value
  // ============================================
  float * mat = malloc( rows * cols * sizeof(float));

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      mat[i * cols + j] = 0.0;
    }
  }

  return mat;
}


void print_mat(float * mat, int rows, int cols) {
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      printf("%f ", mat[i * cols + j]);
    }
    printf("\n");
  }
}



// ============================================
// Comparing two matrices of the same size for correctness
// ============================================
bool compare_matrices(float * mat1, float * mat2, int rows, int cols) {
  bool equal = true;
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      int index = i * cols + j;
      bool check = (mat1[index] == mat2[index]);
      equal = equal & check;
    }
  }
  return equal;
}


// ============================================
// Implementation of naive matrix multiplication
// a = b * c
// a: matrix of dimension out_rows x out_cols
// b: matrix of dimension out_rows x in_cols
// c: matrix of dimension in_cols x out_cols
// ============================================
void naivemm(float * a, float * b, float * c, int out_rows, int out_cols, int in_cols) {
  int tot_counter = 0, rep_counter = 0;
  for (int i = 0; i < out_rows; i++) {
    for (int j = 0; j < out_cols; j++) {
      for (int k = 0; k < in_cols; k++) {
        int a_index = i * out_cols + j;
        int b_index = i * in_cols + k;
        int c_index = k * out_cols + j;

        a[a_index] = a[a_index] + (b[b_index] * c[c_index]);
      }
    }
  }
}


/*=============================================
getTile returns the tile of a matrix at a specific index
a: matrix of dimension in_rows x in_cols
=============================================*/
float * getTile(float *a, int tile_index_x, int tile_index_y, int in_cols, int numblks) {
  float *new_tile = generate_output(numblks, numblks);
  for (int i = 0; i < numblks; i++) {
    for (int j = 0; j < numblks; j ++ ) {
      int index = in_cols * (tile_index_x * numblks + i) + (tile_index_y * numblks + j);
      int new_tile_index = i * numblks + j;
      new_tile[new_tile_index] = a[index];
    }
  }
  return new_tile;
}


/*========================================
tileAccumulate multiplies matrix "b" and matrix "c" and adds the tile to the final matrix "a"
a: matrix of dimension out_rows x out_cols
b: tile of dimension out_rows x in_cols
c: tile of dimension in_cols x out_cols
========================================*/
void tileAccumulate(float * a, float * b, float * c, int in_cols, int out_rows, int out_cols, int numblks) {
  int N = out_rows/numblks;
  for (int i = 0; i < N; i++) {
    for (int j= 0; j < N; j++) {
      for (int k = 0; k < N; k++) {
        float * a_tile = getTile(a, i, j, out_cols, numblks);
        float * b_tile = getTile(b, i, k, in_cols, numblks);
        float * c_tile = getTile(c, k, j, out_cols, numblks);
        naivemm(a_tile, b_tile, c_tile, numblks, numblks, numblks);
        for (int p = 0; p < numblks; p++) {
          for (int q = 0; q < numblks; q ++) {
            int a_index = out_cols * (i * numblks  + p) + (j * numblks + q);
            int tile_index = p * numblks + q;
            a[a_index] = a_tile[tile_index];
          }
        }
      }
    }
  }
}


int main() {

  int MATRIX_ROWS = 32;
  int MATRIX_COLS = MATRIX_ROWS; // for a square matrix
  int numblks = 16;

  clock_t start_clock_naive, end_clock_naive, start_clock_tiled, end_clock_tiled;
  double cpu_time_naive, cpu_time_tiled;
  int number_of_iterations = 1; // TODO: Set this for consistent results

  float * mat_a_naive = generate_output(MATRIX_ROWS, MATRIX_COLS);
  float * mat_a_tiled = generate_output(MATRIX_ROWS, MATRIX_COLS);
  float * mat_b = generate_rand_input(MATRIX_ROWS, MATRIX_COLS);
  float * mat_c = generate_rand_input(MATRIX_ROWS, MATRIX_COLS);


  // ============================================
  // Running and profiling for naive
  // ============================================
  start_clock_naive = clock();
  for (int iter = 0; iter < number_of_iterations; iter++) {
    naivemm(mat_a_naive, mat_b, mat_c, MATRIX_ROWS, MATRIX_COLS, MATRIX_COLS);
  }
  end_clock_naive = clock();


  // =============================================
  // Running and profiling for tiled
  // =============================================
  if (log(numblks)/log(2) - (round( log(numblks)/log(2) ) == 0) && numblks <= MATRIX_ROWS) {
    start_clock_tiled = clock();
    for (int iter = 0; iter < number_of_iterations; iter++) {
      tileAccumulate(mat_a_tiled, mat_b, mat_c, MATRIX_ROWS, MATRIX_COLS, MATRIX_COLS, numblks);
    }
    end_clock_tiled = clock();
  }

  else {
    printf("You entered an invalid sub-block size for the tiled implementation... \n");
  }
  // Print final output matrix for debugging purposes. Can comment out if not
  // needed.
  //
  //print_mat(mat_a, MATRIX_ROWS, MATRIX_COLS);

  // TODO: Comparing matrices with golden matrix-multiplication implementation
  // (naive). Change this code to verify that optimized tiled implementation is
  // also correct.
  if ( compare_matrices(mat_a_naive, mat_a_naive, MATRIX_ROWS, MATRIX_COLS) ) {
    printf("Matrix multiplication is functionally correct.\n");
  } else {
    printf("[Error] Matrix multiplication is not functionally correct...\n");
  }

  // Compute execution time.
  printf("=========================================\n");
  cpu_time_naive = ( (double) (end_clock_naive - start_clock_naive) ) / CLOCKS_PER_SEC;
  printf("Total execution time for naive implementation: \t\t %lf seconds \n", cpu_time_naive);
  cpu_time_naive = cpu_time_naive / (double) number_of_iterations; // time per iteration
  printf("Per iteration execution time for naive implementation: \t %lf seconds \n", cpu_time_naive);
  printf("------------------------------------------\n");
  cpu_time_tiled = ( (double) (end_clock_tiled - start_clock_tiled) ) / CLOCKS_PER_SEC;
  printf("Total execution time for tiled implementation: \t\t %lf seconds \n", cpu_time_tiled);
  cpu_time_tiled = cpu_time_tiled / (double) number_of_iterations;
  printf("Per iteration execution time for tiled implementation: \t %lf seconds \n", cpu_time_tiled);
  printf("=========================================\n\n");

  // ============================================
  // Freeing matrices before ending the code
  // ============================================
  free(mat_a_naive);
  free(mat_a_tiled);
  free(mat_b);
  free(mat_c);


  return 0;
}
