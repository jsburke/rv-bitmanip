#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <ctype.h>
#include <string.h>
#include "bitmanip.h"

#ifdef RV32
const int bitness = 32;
#else // RV64
const int bitness = 64;
#endif

#define REPL_LEN   256
#define VAR_COUNT  16
#define RS_COUNT   3
#define ARGS_COUNT 16

void str_lower(char *s){
  for(;*s;++s) *s = tolower(*s);
}

typedef enum insn {INVALID,
                   CLZ,
                   CTZ,
                   PCNT,
                   SRO,
                   SLO,
                   ROR,
                   ROL,
                   GREV,
                   SHFL,
                   UNSHFL,
                   BEXT,
                   BDEP,
                   ANDC,
#ifdef RV64  // OP-32 instructions
                   CLZW,
                   CTZW,
                   PCNTW,
                   SROW,
                   SLOW,
                   RORW,
                   ROLW,
                   SHFLW,
                   UNSHFLW,
                   BEXTW,
                   BDEPW,
#endif
//                   STORE_MULT,
//                   STORE,
//                   PRINT,
                   EXIT} insn_t;

insn_t insn_key(char *insn_str){

  str_lower(insn_str); // make our life with strncmp a bit simpler

#ifdef RV64 // OP-32 instructions
  if(strncmp(insn_str, "clzw",    4) == 0) return CLZW;
  if(strncmp(insn_str, "ctzw",    4) == 0) return CTZW;
  if(strncmp(insn_str, "pcntw",   5) == 0) return PCNTW;
  if(strncmp(insn_str, "slow",    4) == 0) return SLOW;
  if(strncmp(insn_str, "srow",    4) == 0) return SROW;
  if(strncmp(insn_str, "rorw",    4) == 0) return RORW;
  if(strncmp(insn_str, "rolw",    4) == 0) return ROLW;
  if(strncmp(insn_str, "shflw",   5) == 0) return SHFLW;
  if(strncmp(insn_str, "unshflw", 7) == 0) return UNSHFLW;
  if(strncmp(insn_str, "bextw",   5) == 0) return BEXTW;
  if(strncmp(insn_str, "bdepw",   5) == 0) return BDEPW;
#endif
  if(strncmp(insn_str, "clz",    3)  == 0) return CLZ;
  if(strncmp(insn_str, "ctz",    3)  == 0) return CTZ;
  if(strncmp(insn_str, "pcnt",   4)  == 0) return PCNT;
  if(strncmp(insn_str, "slo",    3)  == 0) return SLO;
  if(strncmp(insn_str, "sro",    3)  == 0) return SRO;
  if(strncmp(insn_str, "ror",    3)  == 0) return ROR;
  if(strncmp(insn_str, "rol",    3)  == 0) return ROL;
  if(strncmp(insn_str, "grev",   4)  == 0) return GREV;
  if(strncmp(insn_str, "shfl",   4)  == 0) return SHFL;
  if(strncmp(insn_str, "unshfl", 6)  == 0) return UNSHFL;
  if(strncmp(insn_str, "bext",   4)  == 0) return BEXT;
  if(strncmp(insn_str, "bdep",   4)  == 0) return BDEP;
  if(strncmp(insn_str, "andc",   4)  == 0) return ANDC;
  if(strncmp(insn_str, "exit",   4)  == 0) return EXIT;

  // scratch mem controls
//  if(strncmp(insn_str, "store_m", 7) == 0) return STORE_MULT;
//  if(strncmp(insn_str, "store",   5) == 0) return STORE;
//  if(strncmp(insn_str, "print",   5) == 0) return PRINT;

  return INVALID;
}

void eval_print(insn_t insn, xlen_t *nums){
  xlen_t res;
  if(insn == INVALID) printf("\n  Invalid Operation");
  else if(insn == EXIT) printf("\n Exiting\n");
  else {
    res = (insn == CLZ)      ? clz(nums[0]) :
          (insn == CTZ)      ? ctz(nums[0]) :
          (insn == PCNT)     ? pcnt(nums[0]) :
          (insn == SRO)      ? sro(nums[0], nums[1]) :
          (insn == SLO)      ? slo(nums[0], nums[1]) :
          (insn == ROR)      ? ror(nums[0], nums[1]) :
          (insn == ROL)      ? rol(nums[0], nums[1]) :
          (insn == GREV)     ? grev(nums[0], nums[1]) :
          (insn == SHFL)     ? shfl(nums[0], nums[1]) :
          (insn == UNSHFL)   ? unshfl(nums[0], nums[1]) :
          (insn == BEXT)     ? bext(nums[0], nums[1]) :
          (insn == BDEP)     ? bdep(nums[0], nums[1]) :
#ifdef RV64
          (insn == CLZW)     ? clzw(nums[0]) :
          (insn == CTZW)     ? ctzw(nums[0]) :
          (insn == PCNTW)    ? pcntw(nums[0]) :
          (insn == SROW)     ? srow(nums[0], nums[1]) :
          (insn == SLOW)     ? slow(nums[0], nums[1]) :
          (insn == RORW)     ? rorw(nums[0], nums[1]) :
          (insn == ROLW)     ? rolw(nums[0], nums[1]) :
          (insn == SHFLW)    ? shflw(nums[0], nums[1]) :
          (insn == UNSHFLW)  ? unshflw(nums[0], nums[1]) :
          (insn == BEXTW)    ? bextw(nums[0], nums[1]) :
          (insn == BDEPW)    ? bdepw(nums[0], nums[1]) :
#endif
                               andc(nums[0], nums[1]);
  
    printf("\n   %0" PR_HEX, res);
  }
}

int main(){

  insn_t insn;         // operation to perform
//  xlen_t scratch      [VAR_COUNT] = {0};
  xlen_t cli_nums     [ARGS_COUNT];
 
  char  *cli_letters = (char *) malloc(REPL_LEN * sizeof(char));
  size_t cli_sz = REPL_LEN;
  size_t cli_count;
 
  char *token;

  printf("**********************************\n");
  printf("*                                *\n");
  printf("* %dbit BitManip REPL            *\n", bitness);
  printf("*                                *\n");
  printf("* Usage:                         *\n");
  printf("*                                *\n");
  printf("* exit - close this tool         *\n");
  printf("*                                *\n");
  printf("* insn rs1 rs2                   *\n");
  printf("*      calculate result of insn  *\n");
  printf("*      given the two inputs.     *\n");
  printf("*      Some ops ignore rs2.      *\n");
  printf("*                                *\n");
  printf("**********************************\n");

  while(insn != EXIT){

    insn = INVALID; //prefill

    printf("\n > ");
    cli_count = getline(&cli_letters, &cli_sz, stdin);
  
    if(cli_count > REPL_LEN){
      printf("\n  Prior command was longer than repl buffer.");
      continue;
    }
 
    fflush(stdin);

    token = strtok(cli_letters, " ");
    insn = insn_key(token);

    int i = 0;
    while((i < ARGS_COUNT)){
      if((token = strtok(NULL, " ")) == NULL) break;
      cli_nums[i] = strtoull(token, NULL, 0);
      i++;
    }

    eval_print(insn, cli_nums);

  } // end of repl loop
  return 0;
}
