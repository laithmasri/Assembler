%{
#include <stdlib.h>
#include <stdio.h>

enum instruction_format { IF_R, IF_I, IF_UI, IF_S, IF_B, IF_J };

static struct instruction {
  enum instruction_format format;
  int funct3 : 3;
  int funct7 : 7;
  int imm : 20;
  int opcode : 7;
  int rd : 5;
  int rs1 : 5;
  int rs2 : 5;
} instruction;

static void printbin(int val, char bits);
static int bit_range(int val, char begin, char end);
static void print_instruction(struct instruction);
int yylex();
void yyerror(char* s);
%}

%start program
%union {
  long l;
}
%token <l> REGISTER NEWLINE COMMA LEFT_PAREN RIGHT_PAREN MINUS IMMEDIATE
%token ADD SUB ADDI LW SW BEQ J AUIPC
%type <l> imm

%%
program : segments
	;

segments : segments segment
	 | segment
	 ;

segment : %empty
	| text
	;

text : text NEWLINE instruction
     | instruction
     ;

instruction : r-type
{
  print_instruction(instruction);
}
;
r-type : add
{
  instruction.format = IF_R;
}
|sub
{
  instruction.format = IF_R;
}
;
add: ADD REGISTER COMMA REGISTER COMMA REGISTER
{
  instruction.funct7 = 0b0000000;
  instruction.rs2 = $6;
  instruction.rs1 = $4;
  instruction.funct3 = 0b000;
  instruction.rd = $2;
  instruction.opcode = 0b0110011;
}
;
sub: SUB REGISTER COMMA REGISTER COMMA REGISTER
{
  instruction.funct7 = 0b0100000;
  instruction.rs2 = $6;
  instruction.rs1 = $4;
  instruction.funct3 = 0b000;
  instruction.rd = $2;
  instruction.opcode = 0b0110011;
}

instruction : i-type
{
  print_instruction(instruction);
}
;
i-type : addi
{
  instruction.format = IF_I;
}  
|lw
{
  instruction.format = IF_I;
}
;
addi: ADDI REGISTER COMMA REGISTER COMMA imm
{
  instruction.imm = $6;
  instruction.rs1 = $4;
  instruction.funct3 = 0b000;
  instruction.rd = $2;
  instruction.opcode = 0b0010011;
} 
;
lw: LW REGISTER COMMA imm LEFT_PAREN REGISTER RIGHT_PAREN
{
  instruction.imm = $4;
  instruction.rs1 = $6;
  instruction.funct3 = 0b010;
  instruction.rd = $2;
  instruction.opcode = 0b0000011;
}
;
instruction : s-type
{
  print_instruction(instruction);
}
;
s-type : sw
{
  instruction.format = IF_S;
}
|beq
{
  instruction.format = IF_S;
}
;
sw: SW REGISTER COMMA imm LEFT_PAREN REGISTER RIGHT_PAREN
{
  instruction.imm = $4;
  instruction.rs2 = $2;
  instruction.rs1 = $6;
  instruction.funct3 = 0b010;
  instruction.opcode = 0b0100011;
}
;
beq : BEQ REGISTER COMMA REGISTER COMMA imm
{
  instruction.imm = $6;
  instruction.rs2 = $4;
  instruction.rs1 = $2;
  instruction.funct3 = 0b000;
  instruction.opcode = 0b1100011;
}
;
instruction : u-type
{
  print_instruction(instruction);
}
;
u-type : j
{
  instruction.format = IF_J;
}
|auipc
{
  instruction.format = IF_UI;
}
;
j: J imm
{
  instruction.imm = $2;
  instruction.rd = 0b00000;
  instruction.opcode = 0b1101111;
}
;
auipc: AUIPC REGISTER COMMA imm
{
  instruction.imm = $4;
  instruction.rd = $2;
  instruction.opcode = 0b0010111;
}
;

imm : MINUS IMMEDIATE
{
$$ = -1 * $2;
}
| IMMEDIATE
{
$$ = $1;
}
;
%%
static void print_instruction(struct instruction instruction) {
  switch (instruction.format) {
    case IF_R:
	printbin(instruction.funct7, 7);
	printbin(instruction.rs2, 5);
	printbin(instruction.rs1, 5);
	printbin(instruction.funct3, 3);
	printbin(instruction.rd, 5);
	printbin(instruction.opcode, 7);
      break;
    case IF_I:
	printbin(instruction.imm, 12);
	printbin(instruction.rs1, 5);
	printbin(instruction.funct3, 3);
	printbin(instruction.rd, 5);
	printbin(instruction.opcode, 7);
      break;
    case IF_UI:
	printbin(instruction.imm, 20);
	printbin(instruction.rd, 5);
	printbin(instruction.opcode, 7);
      break;
    case IF_S:
	//firstSevenBits = bit_range(instruction.imm, 0, 7);
  printbin(bit_range(instruction.imm, 5, 12), 7);
	printbin(instruction.rs2, 5);
	printbin(instruction.rs1, 5);
	printbin(instruction.funct3, 3);
	printbin(bit_range(instruction.imm, 0, 5), 5);
	printbin(instruction.opcode, 7);
      break;
    case IF_B:
	printbin(bit_range(instruction.imm, 5, 12), 7);
	printbin(instruction.rs2, 5);
	printbin(instruction.rs1, 5);
	printbin(instruction.funct3, 3);
	printbin(bit_range(instruction.imm, 0, 5), 5);
	printbin(instruction.opcode, 7);
      break;
    case IF_J:
	printbin(instruction.imm, 20);
  printbin(instruction.rd, 5);
  printbin(instruction.opcode, 7);
      break;
    default:
      exit(-1);
  }
  printf("\n");
}
static void printbin(int val, char bits) {
  for (char i = bits - 1; i >= 0; i--) {
    if (val & (1 << i)) {
      putchar('1');
    } else {
      putchar('0');
    }
  }
}

static int bit_range(int val, char begin, char end) {
  int mask = ((1 << end) - 1) ^ ((1 << begin) - 1);
  return (val & mask) >> begin;
}

void yyerror(char *msg){
    // If your assembler cannot parse input it will exit, make sure to test locally using the tests on canvas
}

int main(){
 #ifdef YYDEBUG
 int yydebug = 1;
 #endif /* YYDEBUG */
 yyparse();
 return 0;
}
