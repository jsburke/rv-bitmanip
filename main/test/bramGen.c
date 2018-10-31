#include <stdio.h>
#include <stdlib.h>
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

  int shifts = (XLEN == 32) ? 8 : 16;
  for(int i = 0; i < shifts; i++){ // alternating zeros and ones 
    arr[start]      <<=  4;    // shift up by nibble
    arr[start + 1]  <<=  4;    // can be done faster but meh
    arr[start]      +=   5;        
    arr[start + 1]  += 0xA;
  }
}

void xlen_arr_fill(FILE *urand, xlen_t *arr, int start, int len){
  for(int i = start; i < len; i++)
    arr[i] = rand_val(urand);
}

///////////////////////////////////////
//                                   //
//  Meat                             //
//                                   //
///////////////////////////////////////

int main(int argc, char *argv[]){

  if(argc != 2){
    printf("*******  ERROR  *******\n");
    printf("  bramGen requires one \n");
    printf("  argument to know how \n");
    printf("  many entries to create\n\n");
    return 1;
  }

  long no_entries = strtol(argv[1], NULL, 10);
  no_entries = (no_entries > 8) ? no_entries : 8;  //cover corner cases at least

  xlen_t rs1[no_entries];
//  xlen_t rs2[no_entries];

  xlen_corner_cases(rs1, 0);

  printf("rs1 values:\n\n");
  for(int i = 0; i < 8; i++) printf("    rs1[%d] : %" PR_HEX "\n", i, rs1[i]);

//  FILE *urand = rand_init();

  return 0;
}
