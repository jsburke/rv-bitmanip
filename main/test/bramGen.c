#include <stdio.h>
#include <stdint.h>
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


