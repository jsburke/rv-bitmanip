#include <inttypes.h>
#include "bitmanip.h"

// andc is a bit of a thumb
xlen_t andc(xlen_t rs1, xlen_t rs2){
  return rs1 & ~rs2;
}

//static functions that other ones wrap
static xlen_t clz_generic(xlen_t rs1, int xlen){
  for(int count = 0; count < xlen; count++){
    if(rs1 >> (XLEN - 1)) return count;
    rs1 <<= 1;
  }
  return xlen;
}

static xlen_t ctz_generic(xlen_t rs1, int xlen){
  for(int count = 0; count < xlen; count++)
    if((rs1 >> count) & 1)
      return count;
  return xlen;
}

static xlen_t pcnt_generic(xlen_t rs1, int xlen){
  xlen_t count = 0;
  for(int index = 0; index < xlen; index++)
    count += (rs1 >> index) & 1;
  return count;
}

static xlen_t slo_generic(xlen_t rs1, xlen_t rs2, int xlen){
  int shamt = rs2 & (xlen - 1);
  return ~(~rs1 << shamt);
}

static xlen_t sro_generic(xlen_t rs1, xlen_t rs2, int xlen){
  int shamt = rs2 & (xlen - 1);
  return ~(~rs1 >> shamt);
}

static xlen_t rol_generic(xlen_t rs1, xlen_t rs2, int xlen){
  int shamt = rs2 & (xlen - 1);
  return (rs1 << shamt) | (rs1 >> ((xlen - shamt) & (xlen - 1)));
}

static xlen_t ror_generic(xlen_t rs1, xlen_t rs2, int xlen){
  int shamt = rs2 & (xlen - 1);
  return (rs1 >> shamt) | (rs1 << ((xlen - shamt) & (xlen - 1)));
}

static xlen_t bext_generic(xlen_t rs1, xlen_t rs2, int xlen){
  xlen_t r = 0;
  xlen_t one = 1;

  for(int i = 0, j = 0; i < xlen; i++)
    if((rs2 >> i) & 1){
      if((rs1 >> i) & 1)
        r |= one << j;
      j++;
    }
  return r;
}

static xlen_t bdep_generic(xlen_t rs1, xlen_t rs2, int xlen){
  xlen_t r = 0;
  xlen_t one = 1;

  for(int i = 0, j = 0; i < xlen; i++)
    if((rs2 >> i) & 1){
      if((rs1 >> j) & 1)
        r |= one << i;
      j++;
    }
  return r;
}

xlen_t clz(xlen_t rs1){
  return clz_generic(rs1, XLEN);
}

xlen_t ctz(xlen_t rs1){
  return ctz_generic(rs1, XLEN);
}

xlen_t pcnt(xlen_t rs1){
  return pcnt_generic(rs1, XLEN);
}

xlen_t slo(xlen_t rs1, xlen_t rs2){
  return slo_generic(rs1, rs2, XLEN);
}

xlen_t sro(xlen_t rs1, xlen_t rs2){
  return sro_generic(rs1, rs2, XLEN);
}

xlen_t rol(xlen_t rs1, xlen_t rs2){
  return rol_generic(rs1, rs2, XLEN);
}

xlen_t ror(xlen_t rs1, xlen_t rs2){
  return ror_generic(rs1, rs2, XLEN);
}

xlen_t bext(xlen_t rs1, xlen_t rs2){
  return bext_generic(rs1, rs2, XLEN);
}

xlen_t bdep(xlen_t rs1, xlen_t rs2){
  return bdep_generic(rs1, rs2, XLEN);
}


// static fn for shuffle instructions
static xlen_t shuffle_stage(xlen_t src, xlen_t maskL, xlen_t maskR, int N){
  xlen_t x = src & ~(maskL | maskR);
  x |= ((src << N) & maskL) | ((src >> N) & maskR);
  return x;
}

#ifdef RV32
xlen_t grev(xlen_t rs1, xlen_t rs2){
  xlen_t x = rs1;
  int shamt  = rs2 & 31;

  if(shamt &  1) x = ((x & 0x55555555) <<  1) | ((x & 0xAAAAAAAA) >>  1);
  if(shamt &  2) x = ((x & 0x33333333) <<  2) | ((x & 0xCCCCCCCC) >>  2);
  if(shamt &  4) x = ((x & 0x0F0F0F0F) <<  4) | ((x & 0xF0F0F0F0) >>  4);
  if(shamt &  8) x = ((x & 0x00FF00FF) <<  8) | ((x & 0xFF00FF00) >>  8);
  if(shamt & 16) x = ((x & 0x0000FFFF) << 16) | ((x & 0xFFFF0000) >> 16);
  return x;
}

xlen_t shfl(xlen_t rs1, xlen_t rs2){
  xlen_t x = rs1;
  if(rs2 & 8) x = shuffle_stage(x, 0x00FF0000, 0x0000FF00, 8);
  if(rs2 & 4) x = shuffle_stage(x, 0x0F000F00, 0x00F000F0, 4);
  if(rs2 & 2) x = shuffle_stage(x, 0x30303030, 0x0C0C0C0C, 2);
  if(rs2 & 1) x = shuffle_stage(x, 0x44444444, 0x22222222, 1);
  return x;
}

xlen_t unshfl(xlen_t rs1, xlen_t rs2){
  xlen_t x = rs1;
  if(rs2 & 1) x = shuffle_stage(x, 0x44444444, 0x22222222, 1);
  if(rs2 & 2) x = shuffle_stage(x, 0x30303030, 0x0C0C0C0C, 2);
  if(rs2 & 4) x = shuffle_stage(x, 0x0F000F00, 0x00F000F0, 4);
  if(rs2 & 8) x = shuffle_stage(x, 0x00FF0000, 0x0000FF00, 8);
  return x;
}

#elif RV64

xlen_t grev(xlen_t rs1, xlen_t rs2){
  xlen_t x = rs1;
  int shamt  = rs2 & 63;
  if(shamt &  1)  x = ((x & 0x5555555555555555LL) <<   1) | ((x & 0xAAAAAAAAAAAAAAAALL) >>   1);
  if(shamt &  2)  x = ((x & 0x3333333333333333LL) <<   2) | ((x & 0xCCCCCCCCCCCCCCCCLL) >>   2);
  if(shamt &  4)  x = ((x & 0x0F0F0F0F0F0F0F0FLL) <<   4) | ((x & 0xF0F0F0F0F0F0F0F0LL) >>   4);
  if(shamt &  8)  x = ((x & 0x00FF00FF00FF00FFLL) <<   8) | ((x & 0xFF00FF00FF00FF00LL) >>   8);
  if(shamt & 16)  x = ((x & 0x0000FFFF0000FFFFLL) <<  16) | ((x & 0xFFFF0000FFFF0000LL) >>  16);
  if(shamt & 32)  x = ((x & 0x00000000FFFFFFFFLL) <<  32) | ((x & 0xFFFFFFFF00000000LL) >>  32);
  return x;
}

xlen_t shfl(xlen_t rs1, xlen_t rs2){
  xlen_t x  = rs1;
  int shamt = rs2 & 31;

  if(shamt & 16) x = shuffle_stage(x, 0x0000FFFF00000000LL, 0x00000000FFFF0000LL, 16);
  if(shamt &  8) x = shuffle_stage(x, 0x00FF000000FF0000LL, 0x0000FF000000FF00LL,  8);
  if(shamt &  4) x = shuffle_stage(x, 0x0F000F000F000F00LL, 0x00F000F000F000F0LL,  4);
  if(shamt &  2) x = shuffle_stage(x, 0x3030303030303030LL, 0x0C0C0C0C0C0C0C0CLL,  2);
  if(shamt &  1) x = shuffle_stage(x, 0x4444444444444444LL, 0x2222222222222222LL,  1);
  return x;
}

xlen_t unshfl(xlen_t rs1, xlen_t rs2){
  xlen_t x = rs1;
  int shamt = rs2 & 31;

  if(shamt &  1) x = shuffle_stage(x, 0x4444444444444444LL, 0x2222222222222222LL,  1);
  if(shamt &  2) x = shuffle_stage(x, 0x3030303030303030LL, 0x0C0C0C0C0C0C0C0CLL,  2);
  if(shamt &  4) x = shuffle_stage(x, 0x0F000F000F000F00LL, 0x00F000F000F000F0LL,  4);
  if(shamt &  8) x = shuffle_stage(x, 0x00FF000000FF0000LL, 0x0000FF000000FF00LL,  8);
  if(shamt & 16) x = shuffle_stage(x, 0x0000FFFF00000000LL, 0x00000000FFFF0000LL, 16);
  return x;
}

// OP-32 insns
xlen_t upper_32 = 0xFFFFFFFF00000000LL;
xlen_t lower_32 = 0x00000000FFFFFFFFLL; 

xlen_t clzw(xlen_t rs1){
  return clz_generic(rs1 << 32, 32);
}

xlen_t ctzw(xlen_t rs1){
  return ctz_generic(rs1 & lower_32, 32);
}

xlen_t pcntw(xlen_t rs1){
  return pcnt_generic(rs1 & lower_32, 32);
}

xlen_t slow(xlen_t rs1, xlen_t rs2){
  return lower_32 & slo_generic(rs1 & lower_32, rs2 & 31, 32);
}

xlen_t srow(xlen_t rs1, xlen_t rs2){
  xlen_t sro_raw = sro_generic(rs1 & lower_32, rs2 & 31, 32);
  return ((sro_raw & upper_32) >> 32) | (sro_raw & lower_32);
}

xlen_t rolw(xlen_t rs1, xlen_t rs2){
  xlen_t rol_raw = rol_generic(rs1 & lower_32, rs2 & 31, 32);
  return ((rol_raw & upper_32) >> 32) | (rol_raw & lower_32);
}

xlen_t rorw(xlen_t rs1, xlen_t rs2){
  xlen_t ror_raw = ror_generic(rs1 & lower_32, rs2 & 31, 32);
  return ((ror_raw & upper_32) >> 32) | (ror_raw & lower_32);
}

xlen_t bextw(xlen_t rs1, xlen_t rs2){
  return bext_generic(rs1 & lower_32, rs2 & lower_32, 32);
}

xlen_t bdepw(xlen_t rs1, xlen_t rs2){
  return bdep_generic(rs1 & lower_32, rs2 & lower_32, 32);
}


// leaving (un)shflw operations commented because it was a fun exercize
// and may help someone's understanding in the future
//
// uncommenting these and re-enabling in the repl will show that they
// are covered by (un)shfl so long as the only bits set in rs2 are of the four lowest
/*xlen_t shflw(xlen_t rs1, xlen_t rs2){
  xlen_t x     = rs1 & lower_32;
  int    shamt = rs2 & 15;
  return shfl(x, shamt);
}

xlen_t unshflw(xlen_t rs1, xlen_t rs2){
  xlen_t x     = rs1 & lower_32;
  int    shamt = rs2 & 15;
  return unshfl(x, shamt);
}*/

// 32 bit mode grev and shfl in RV64
// not real insns, mainly for testing ease
xlen_t grev_32(xlen_t rs1, xlen_t rs2){
  return grev(rs1 & lower_32, rs2 & 31);
}

xlen_t shfl_32(xlen_t rs1, xlen_t rs2){
  return shfl(rs1 & lower_32, rs2 & 15);
}

xlen_t unshfl_32(xlen_t rs1, xlen_t rs2){
  return unshfl(rs1 & lower_32, rs2 & 15);
}
#endif
