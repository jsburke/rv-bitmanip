#ifndef BITMANIP_H
#define BITMANIP_H

#include <stdint.h>

#ifdef RV32
#define XLEN 32
typedef uint32_t xlen_t;
#elif  RV64
#define XLEN 64
typedef uint64_t xlen_t;
#else
#error "RV32 or RV64 must be declared"
#endif

// single operand instructions
xlen_t clz (xlen_t rs1);
xlen_t ctz (xlen_t rs1);
xlen_t pcnt(xlen_t rs1);

// two operand instructions
xlen_t andc(xlen_t rs1, xlen_t rs2);
xlen_t slo (xlen_t rs1, xlen_t rs2);
xlen_t sro (xlen_t rs1, xlen_t rs2);
xlen_t rol (xlen_t rs1, xlen_t rs2);
xlen_t ror (xlen_t rs1, xlen_t rs2);
xlen_t bext(xlen_t rs1, xlen_t rs2);
xlen_t bdep(xlen_t rs1, xlen_t rs2);

// width strict
uint64_t grev64(uint64_t rs1, uint64_t rs2);
uint32_t grev32(uint32_t rs1, uint32_t rs2);

uint64_t shfl64  (uint64_t rs1, uint64_t rs2);
uint64_t unshfl64(uint64_t rs1, uint64_t rs2);

uint32_t shfl32  (uint32_t rs1, uint32_t rs2);
uint32_t unshfl32(uint32_t rs1, uint32_t rs2);

#endif //BITMANIP_H
