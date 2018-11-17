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
  fread(&val, sizeof(xlen_t), 1, urand); // causes -Wunused-variable to yell, don't care
  return val;
}

void rand_close(FILE *urand){
  fclose(urand);
}

// array writers

#define NO_CORNER_CASES 8

void xlen_corner_cases(xlen_t *arr, int first){

  int idx    = first;

  arr[idx++] =                     0;  // zeros
  arr[idx++] =                     1;  // LSB
  arr[idx++] =                    -1;  // ones
  arr[idx++] =               -1 & ~1;  // LSB zero
  arr[idx++] =    1ULL << (XLEN - 1);  // MSB 

  xlen_t msb = arr[idx - 1];

  arr[idx++] =                  ~msb;  // MSB unset

  int shifts = (XLEN == 32) ? 8 : 16;
  for(int i = 0; i < shifts; i++){ // alternating zeros and ones 
    arr[idx]      <<=  4;    // shift up by nibble
    arr[idx + 1]  <<=  4;    // can be done faster but meh
    arr[idx]      +=   5;        
    arr[idx + 1]  += 0xA;
  }
}

void xlen_arr_fill(FILE *urand, xlen_t *arr, int first, int len){
  for(int i = first; i < len; i++)
    arr[i] = rand_val(urand);
}

// file writer
void xlen_hex_write(const char *file, xlen_t *arr, int len){
  FILE *fp = fopen(file, "w");
  if(file == NULL){
    printf("failed to open %s, exitting", file);
    exit(EXIT_FAILURE);
  }
  
  for(int i = 0; i < len; i++){
    fprintf(fp, "%0*" PR_HEX "\n", XLEN/4, arr[i]);
  }
  fclose(fp);
}

///////////////////////////////////////
//                                   //
//  Meat                             //
//                                   //
///////////////////////////////////////

int main(int argc, char *argv[]){

  // basic program prep
  if(argc != 2){
    printf("*******  ERROR  *******\n");
    printf("  bramGen requires one \n");
    printf("  argument to know how \n");
    printf("  many entries to create\n\n");
    return 1;
  }

  long no_entries = strtol(argv[1], NULL, 10);
  no_entries = (no_entries > 8) ? no_entries : 8;  //cover corner cases at least

  FILE *urand = rand_init();

  // declare source operand values
  xlen_t rs1[no_entries];
  xlen_t rs2[no_entries];

  xlen_corner_cases(rs1, 0);

  xlen_arr_fill(urand, rs1, NO_CORNER_CASES, no_entries);
  xlen_arr_fill(urand, rs2, 0, no_entries);

  rand_close(urand);

  // write sources to file
  xlen_hex_write("./rs1.hex", rs1, no_entries);
  xlen_hex_write("./rs2.hex", rs2, no_entries);

  // generate interesting bit manip based results
  xlen_t res[no_entries];

  // single operand
  for(int i = 0; i < no_entries; i++)
    res[i] = clz(rs1[i]);
  xlen_hex_write("./clz.hex", res, no_entries);

  for(int i = 0; i < no_entries; i++)
    res[i] = ctz(rs1[i]);
  xlen_hex_write("./ctz.hex", res, no_entries);

  for(int i = 0; i < no_entries; i++)
    res[i] = pcnt(rs1[i]);
  xlen_hex_write("./pcnt.hex", res, no_entries);

  // dual operand
  for(int i = 0; i < no_entries; i++)
    res[i] = andc(rs1[i], rs2[i]);
  xlen_hex_write("./andc.hex", res, no_entries);

  for(int i = 0; i < no_entries; i++)
    res[i] = slo(rs1[i], rs2[i]);
  xlen_hex_write("./slo.hex", res, no_entries);

  for(int i = 0; i < no_entries; i++)
    res[i] = sro(rs1[i], rs2[i]);
  xlen_hex_write("./sro.hex", res, no_entries);

  for(int i = 0; i < no_entries; i++)
    res[i] = rol(rs1[i], rs2[i]);
  xlen_hex_write("./rol.hex", res, no_entries);

  for(int i = 0; i < no_entries; i++)
    res[i] = ror(rs1[i], rs2[i]);
  xlen_hex_write("./ror.hex", res, no_entries);

  for(int i = 0; i < no_entries; i++)
    res[i] = bext(rs1[i], rs2[i]);
  xlen_hex_write("./bext.hex", res, no_entries);

  for(int i = 0; i < no_entries; i++)
    res[i] = bdep(rs1[i], rs2[i]);
  xlen_hex_write("./bdep.hex", res, no_entries);

  // more bitness restricted
  for(int i = 0; i < no_entries; i++)
    res[i] = grev(rs1[i], rs2[i]);
  xlen_hex_write("./grev.hex", res, no_entries);

  for(int i = 0; i < no_entries; i++)
    res[i] = shfl(rs1[i], rs2[i]);
  xlen_hex_write("./shfl.hex", res, no_entries);

  for(int i = 0; i < no_entries; i++)
    res[i] = unshfl(rs1[i], rs2[i]);
  xlen_hex_write("./unshfl.hex", res, no_entries);

  return 0;
}
