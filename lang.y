%lex

%%

\n+           return 'NEWLINE'
\s+           /* skip whitespace */
';'           return 'SEMICOLON'
'='           return 'EQUALS'
'+'           return 'PLUS'
'*'           return 'TIMES'
'('           return 'OP'
')'           return 'CP'
'['           return 'OB'
']'           return 'CB'
'{'           return 'OC'
'}'           return 'CC'
','           return 'COMMA'
'var'         return 'VAR'
'function'    return 'function'
[0-9]+        return 'LITERAL'
\w+           return 'WORD'
<<EOF>>       return 'EOF'

/lex

%start program

%%

program
  : statements {
    return {
      type: 'Program',
      body: $1,
    }
  }
  ;

blockStatement
  : OC statements CC {
    $$ = {
      type : 'BlockStatement',
      body : $2,
    }
  }
  ;

statements
  : eol {
    $$ = []
  }
  | eol statement {
    $$ = [$2]
  }
  | statement {
    $$ = [$1]
  }
  | statement statements {
    $$ = [$1].concat($2)
  }
  | emptyStatement
  ;

statement
  : variableDeclaration eol
  | expressionStatement eol
  | declaration         eol
  ;

eol
  : NEWLINE
  | SEMICOLON
  | EOF
  ;

emptyStatement
  : NEWLINE {
    $$ = []
  }
  ;

expressionStatement
  : expression {
    $$ = {
      type       : 'ExpressionStatement',
      expression : $1
    }
  }
  ;

declaration
  : functionDeclaration
  ;

functionDeclaration
  : function identifier OP CP blockStatement {
    $$ = {
      type       : 'FunctionDeclaration',
      id         : $2,
      body       : $5,
      params     : [],
      defaults   : [],
      rest       : null,
      generator  : false,
      expression : false,
    }
  }
  ;

literal
  : LITERAL
    { $$ = { type: 'Literal', value: parseInt($1), raw: $1 } }
  ;

identifier
  : WORD
    { $$ = { type: 'Identifier', name: $1 }}
  ;

expression
  : binaryExpression
  | callExpression
  | arrayExpression
  | literal
  | identifier
  ;

expressionList
  : expression
    {$$ = [$1]}
  | expression COMMA expressionList
    {$$ = $3.concat($1)}
  ;

arrayExpression
  : OB expressionList CB
    {$$ = {
      type     : 'ArrayExpression',
      elements : $2
    }}
  ;

callExpression
  : expression OP CP
    {$$ = {
      type      : 'CallExpression',
      callee    : $1,
      arguments : [],
    }}
  ;

binaryOperator
  : PLUS
  | TIMES
  ;

binaryExpression
  : expression binaryOperator expression
    {$$ = {
      type     : 'BinaryExpression',
      operator : $2,
      left     : $1,
      right    : $3
    }}
  ;

variableDeclaration
  : VAR WORD EQUALS expression
    {$$ = {
      type  : 'VariableDeclaration',
      declarations: [
        {
          type  : 'VariableDeclarator',
          id    : { type: 'Identifier', name: $2 },
          init  : $4,
        }
      ],
      kind : $1
    }}

  ;
