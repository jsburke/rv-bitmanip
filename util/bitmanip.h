#ifndef BITMANIP_H
#define BITMANIP_H

#include <inttypes.h>

#ifdef RV32
#define XLEN 32
typedef uint32_t xlen_t;
#define PR_HEX PRIx32
#define SC_DEC SCNu32
#elif  RV64
#define XLEN 64
typedef uint64_t xlen_t;
#define PR_HEX PRIx64
#define SC_DEC SCNu64
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

// below insns are very bitwidth sensitive
xlen_t grev  (xlen_t rs1, xlen_t rs2);
xlen_t shfl  (xlen_t rs1, xlen_t rs2);
xlen_t unshfl(xlen_t rs1, xlen_t rs2);

#ifdef RV64
// 32 bit insns for 64bit mode
xlen_t clzw (xlen_t rs1);
xlen_t ctzw (xlen_t rs1);
xlen_t pcntw(xlen_t rs1);

xlen_t slow (xlen_t rs1, xlen_t rs2);
xlen_t srow (xlen_t rs1, xlen_t rs2);
xlen_t rolw (xlen_t rs1, xlen_t rs2);
xlen_t rorw (xlen_t rs1, xlen_t rs2);
xlen_t bextw(xlen_t rs1, xlen_t rs2);
xlen_t bdepw(xlen_t rs1, xlen_t rs2);

xlen_t shflw  (xlen_t rs1, xlen_t rs2);
xlen_t unshflw(xlen_t rs1, xlen_t rs2);
#endif

#endif //BITMANIP_H
