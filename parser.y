%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int reg[10];

// LABEL TABLE
struct {
    char name[20];
    int addr;
} labels[50];

int labelCount = 0;

// INSTRUCTION STRUCTURE
#define MAX_INS 100

typedef struct {
    int type;      // 1=MOV, 2=ADD, 3=SUB, 4=LOOP, 5=JMP
    int r1, r2;
    int val;
    int isReg;
    char label[20];
} Instruction;

Instruction ins[MAX_INS];
int insCount = 0;
int pc = 0;

// FUNCTIONS
void addLabel(char *name, int addr) {
    strcpy(labels[labelCount].name, name);
    labels[labelCount].addr = addr;
    labelCount++;
}

int getLabel(char *name) {
    for(int i = 0; i < labelCount; i++)
        if(strcmp(labels[i].name, name) == 0)
            return labels[i].addr;
    return -1;
}

int yylex();
void yyerror(const char *s);
%}

%union {
    int num;
    char str[20];
}

%token MOV ADD SUB LOOP JMP
%token <num> NUM REG
%token <str> LABEL
%token COMMA COLON NEWLINE

%%

program:
    program line
    | /* empty */
;

line:
    instruction NEWLINE
    | LABEL COLON NEWLINE   { addLabel($1, insCount); }
    | NEWLINE
;

instruction:

    MOV REG COMMA NUM
    {
        ins[insCount++] = (Instruction){1, $2, 0, $4, 0, ""};
    }

    | MOV REG COMMA REG
    {
        ins[insCount++] = (Instruction){1, $2, $4, 0, 1, ""};
    }

    | ADD REG COMMA REG
    {
        ins[insCount++] = (Instruction){2, $2, $4, 0, 0, ""};
    }

    | SUB REG COMMA NUM
    {
        ins[insCount++] = (Instruction){3, $2, 0, $4, 0, ""};
    }

    | LOOP LABEL
    {
        Instruction temp = {4, 0, 0, 0, 0, ""};
        strcpy(temp.label, $2);
        ins[insCount++] = temp;
    }

    | JMP LABEL
    {
        Instruction temp = {5, 0, 0, 0, 0, ""};
        strcpy(temp.label, $2);
        ins[insCount++] = temp;
    }
;

%%

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}

int main() {
    printf("Enter Assembly Code:\n");
    yyparse();

    // EXECUTION PHASE
    while(pc < insCount) {

        Instruction in = ins[pc];

        switch(in.type) {

            case 1: // MOV
                if(in.isReg == 0)
                    reg[in.r1] = in.val;
                else
                    reg[in.r1] = reg[in.r2];
                break;

            case 2: // ADD
                reg[in.r1] += reg[in.r2];
                break;

            case 3: // SUB
                reg[in.r1] -= in.val;
                break;

            case 4: // LOOP
            {
                int addr = getLabel(in.label);
                if(reg[0] > 0 && addr != -1) {
                    pc = addr;
                    continue;
                }
                break;
            }

            case 5: // JMP
            {
                int addr = getLabel(in.label);
                if(addr != -1) {
                    pc = addr;
                    continue;
                }
                break;
            }
        }

        pc++;
    }

    printf("\nFinal Register Values:\n");
    for(int i = 0; i < 5; i++)
        printf("R%d = %d\n", i, reg[i]);

    return 0;
}