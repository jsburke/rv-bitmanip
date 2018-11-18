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
                   EXIT} insn_t;

insn_t insn_key(char *insn_str){
  insn_t res = INVALID;
  str_lower(insn_str);
  printf("\ninsn key : %s\n", insn_str);

  if(strncmp(insn_str, "clz",    3)    == 0) res = CLZ;
  if(strncmp(insn_str, "ctz",    3)    == 0) res = CTZ;
  if(strncmp(insn_str, "pcnt",   4)   == 0) res = PCNT;
  if(strncmp(insn_str, "slo",    3)    == 0) res = SLO;
  if(strncmp(insn_str, "sro",    3)    == 0) res = SRO;
  if(strncmp(insn_str, "ror",    3)    == 0) res = ROR;
  if(strncmp(insn_str, "rol",    3)    == 0) res = ROL;
  if(strncmp(insn_str, "grev",   4)   == 0) res = GREV;
  if(strncmp(insn_str, "shfl",   4)   == 0) res = SHFL;
  if(strncmp(insn_str, "unshfl", 6) == 0) res = UNSHFL;
  if(strncmp(insn_str, "bext",   4)   == 0) res = BEXT;
  if(strncmp(insn_str, "bdep",   4)   == 0) res = CLZ;
  if(strncmp(insn_str, "andc",   4)   == 0) res = ANDC;
  if(strncmp(insn_str, "exit",   4)   == 0) res = EXIT;

  return res;
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
