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

#define REPL_LEN 256

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
                   EXIT} insn_t;

insn_t insn_key(char *insn_str){
  str_lower(insn_str);
  printf("\ninsn key : %s\n", insn_str);

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
  if(strncmp(insn_str, "bdepw",   5) == 0) return CLZW;
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
  if(strncmp(insn_str, "bdep",   4)  == 0) return CLZ;
  if(strncmp(insn_str, "andc",   4)  == 0) return ANDC;
  if(strncmp(insn_str, "exit",   4)  == 0) return EXIT;

  return INVALID;
}

void main(){

  insn_t insn = INVALID;

  int word;

  char  *cli_letters = (char *) malloc(REPL_LEN * sizeof(char));
  size_t cli_sz = REPL_LEN;
  size_t cli_count;
 
  char *token;
 
  xlen_t rs1, rs2;

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
  printf("**********************************\n\n");

  while(insn != EXIT){
    printf(" >  ");
    cli_count = getline(&cli_letters, &cli_sz, stdin);
    word = 0;
   
    fflush(stdin);

    token = strtok(cli_letters, " ");
    insn = insn_key(token);
    

/*    while((token = strtok_r(cli_mirror, " ", &cli_mirror))){
      printf("\ntoken = %s", token);
      switch(word){
        case 0 : insn = insn_key(token);
                 break;
        case 1 : rs1  = strtol(token, NULL, 10);
                 break;
        case 2 : rs1  = strtol(token, NULL, 10);
                 break;
      }
    word++;
    }*/
  }
  // end of main
}
