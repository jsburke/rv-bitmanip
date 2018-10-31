#include <stdio.h>
#include <inttypes.h>
#include "bitmanip.h"

// helpers to generate random values
FILE *rand_init(){
  return fopen("/dev/urandom", "rb");
}

xlen_t rand_val(FILE *urand){
  xlen_t val;
  fread(&val, sizeof(xlen_t), 1, urand);
  return val;
}

void rand_close(FILE *urand){
  fclose(urand);
}

// array writers
void xlen_corner_cases(xlen_t *arr, int start){
  arr[start++] =                     0;  // zeros
  arr[start++] =                     1;  // LSB
  arr[start++] =                    -1;  // ones
  arr[start++] =               -1 & ~1;  // LSB zero
  arr[start++] =    1ULL << (XLEN - 1);  // MSB 
  arr[start++] = ~(1ULL << (XLEN - 1));  // MSB unset

  int shifts = (XLEN == 32) ? 4 : 8;
  for(int i = 0; i < shifts; i++){ // alternating
    arr[start]      +=   5;        // zeros and ones
    arr[start + 1]  += 0xA;
    arr[start]     <<= 1;
    arr[start + 1] <<= 1;
  }
}

void xlen_arr_fill(FILE *urand, xlen_t *arr, int start, int len){
  for(int i = start; i < len; i++)
    arr[i] = rand_val(urand);
}

void main(){

  FILE *urand = rand_init();
  printf("random value %" PR_HEX "\n", rand_val(urand));

}
