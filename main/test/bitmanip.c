#include <inttypes.h>
#include "bitmanip.h"

xlen_t clz(xlen_t rs1){
  for(int count = 0; count < XLEN; count++)
    if((rs1 << count) >> (XLEN - 1))
      return count;
  return XLEN;
}

xlen_t ctz(xlen_t rs1){
  for(int count = 0; count < XLEN; count++)
    if((rs1 >> count) & 1)
      return count;
  return XLEN;
}

xlen_t pcnt(xlen_t rs1){
  xlen_t count = 0;
  for(int index = 0; index < XLEN; index++)
    count += (rs1 >> index) & 1;
  return count;
}

xlen_t andc(xlen_t rs1, xlen_t rs2){
  return rs1 & ~rs2;
}

xlen_t slo(xlen_t rs1, xlen_t rs2){
  int shamt = rs2 & (XLEN - 1);
  return ~(~rs1 << shamt);
}

xlen_t sro(xlen_t rs1, xlen_t rs2){
  int shamt = rs2 & (XLEN - 1);
  return ~(~rs1 >> shamt);
}

xlen_t rol(xlen_t rs1, xlen_t rs2){
  int shamt = rs2 & (XLEN - 1);
  return (rs1 << shamt) | (rs1 >> ((XLEN - shamt) & (XLEN - 1)));
}

xlen_t ror(xlen_t rs1, xlen_t rs2){
  int shamt = rs2 & (XLEN - 1);
  return (rs1 >> shamt) | (rs1 << ((XLEN - shamt) & (XLEN - 1)));
}

uint64_t grev64(uint64_t rs1, uint64_t rs2){
  uint64_t x = rs1;
  int shamt  = rs2 & 63;
  if(shamt &  1)  x = ((x & 0x5555555555555555LL) <<   1) | ((x & 0xAAAAAAAAAAAAAAAALL) >>   1);
  if(shamt &  2)  x = ((x & 0x3333333333333333LL) <<   2) | ((x & 0xCCCCCCCCCCCCCCCCLL) >>   2);
  if(shamt &  4)  x = ((x & 0xF0F0F0F0F0F0F0F0LL) <<   4) | ((x & 0x0F0F0F0F0F0F0F0FLL) >>   4);
  if(shamt &  8)  x = ((x & 0x00FF00FF00FF00FFLL) <<   8) | ((x & 0xFF00FF00FF00FF00LL) >>   8);
  if(shamt & 16)  x = ((x & 0x0000FFFF0000FFFFLL) <<  16) | ((x & 0xFFFF0000FFFF0000LL) >>  16);
  if(shamt & 32)  x = ((x & 0x00000000FFFFFFFFLL) <<  32) | ((x & 0xFFFFFFFF00000000LL) >>  32);
  return x;
}

uint32_t grev32(uint32_t rs1, uint32_t rs2){
  uint32_t x = rs1;
  int shamt  = rs2 & 31;
  if(shamt &  1) x = ((x & 0x55555555) <<  1) | ((x & 0xAAAAAAAA) >>  1);
  if(shamt &  2) x = ((x & 0x33333333) <<  2) | ((x & 0xCCCCCCCC) >>  2);
  if(shamt &  4) x = ((x & 0x0F0F0F0F) <<  4) | ((x & 0xF0F0F0F0) >>  4);
  if(shamt &  8) x = ((x & 0x00FF00FF) <<  8) | ((x & 0xFF00FF00) >>  8);
  if(shamt & 16) x = ((x & 0x0000FFFF) << 16) | ((x & 0xFFFF0000) >> 16);
  return x;
}

static uint32_t shuffle32_stage(uint32_t src, uint32_t maskL, uint32_t maskR, int N){
  uint32_t x = src & ~(maskL | maskR);
  x |= ((src << N) & maskL) | ((src >> N) & maskR);
  return x;
}

uint32_t shfl32(uint32_t rs1, uint32_t rs2){
  uint32_t x = rs1;
  if(rs2 & 8) x = shuffle32_stage(x, 0x00FF0000, 0x0000FF00, 8);
  if(rs2 & 4) x = shuffle32_stage(x, 0x0F000F00, 0x00F000F0, 4);
  if(rs2 & 2) x = shuffle32_stage(x, 0x30303030, 0x0C0C0C0C, 2);
  if(rs2 & 1) x = shuffle32_stage(x, 0x44444444, 0x22222222, 1);
  return x;
}

uint32_t unshfl32(uint32_t rs1, uint32_t rs2){
  uint32_t x = rs1;
  if(rs2 & 1) x = shuffle32_stage(x, 0x44444444, 0x22222222, 1);
  if(rs2 & 2) x = shuffle32_stage(x, 0x30303030, 0x0C0C0C0C, 2);
  if(rs2 & 4) x = shuffle32_stage(x, 0x0F000F00, 0x00F000F0, 4);
  if(rs2 & 8) x = shuffle32_stage(x, 0x00FF0000, 0x0000FF00, 8);
  return x;
}

static uint64_t shuffle64_stage(uint64_t src, uint64_t maskL, uint64_t maskR, int N){
  uint64_t x = src & ~(maskL | maskR);
  x |= ((src << N) & maskL) | ((src >> N) & maskR);
  return x;
}

uint64_t shfl64(uint64_t rs1, uint64_t rs2){
  uint64_t x = rs1;
  if(rs2 & 16) x = shuffle64_stage(x, 0x0000FFFF00000000LL, 0x00000000FFFF0000LL, 16);
  if(rs2 &  8) x = shuffle64_stage(x, 0x00FF000000FF0000LL, 0x0000FF000000FF00LL,  8);
  if(rs2 &  4) x = shuffle64_stage(x, 0x0F000F000F000F00LL, 0x00F000F000F000F0LL,  4);
  if(rs2 &  2) x = shuffle64_stage(x, 0x3030303030303030LL, 0x0C0C0C0C0C0C0C0CLL,  2);
  if(rs2 &  1) x = shuffle64_stage(x, 0x4444444444444444LL, 0x2222222222222222LL,  1);
  return x;
}

uint64_t unshfl64(uint64_t rs1, uint64_t rs2){
  uint64_t x = rs1;
  if(rs2 &  1) x = shuffle64_stage(x, 0x4444444444444444LL, 0x2222222222222222LL,  1);
  if(rs2 &  2) x = shuffle64_stage(x, 0x3030303030303030LL, 0x0C0C0C0C0C0C0C0CLL,  2);
  if(rs2 &  4) x = shuffle64_stage(x, 0x0F000F000F000F00LL, 0x00F000F000F000F0LL,  4);
  if(rs2 &  8) x = shuffle64_stage(x, 0x00FF000000FF0000LL, 0x0000FF000000FF00LL,  8);
  if(rs2 & 16) x = shuffle64_stage(x, 0x0000FFFF00000000LL, 0x00000000FFFF0000LL, 16);
  return x;
}

xlen_t bext(xlen_t rs1, xlen_t rs2){
  xlen_t r = 0;
  xlen_t one = 1;

  for(int i = 0, j = 0; i < XLEN; i++)
    if((rs2 >> i) & 1){
      if((rs1 >> i) & 1)
        r |= one << j;  // xlen_t feels funky, cast??
      j++;
    }
  return r;
}

xlen_t bdep (xlen_t rs1, xlen_t rs2){
  xlen_t r = 0;
  xlen_t one = 1;

  for(int i = 0, j = 0; i < XLEN; i++)
    if((rs2 >> i) & 1){
      if((rs1 >> j) & 1)
        r |= one << i;  // xlen_t feels funky, cast??
      j++;
    }
  return r;
}


