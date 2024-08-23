; inherits: python

(parameter (identifier) @variable)
(attribute attribute: (identifier) @property)
(type (identifier) @type)

; Module imports

(import_statement
  (dotted_name (identifier) @type))

(import_statement
  (aliased_import
    name: (dotted_name (identifier) @type)
    alias: (identifier) @type))

(import_from_statement
  (dotted_name (identifier) @type))

(import_from_statement
  (aliased_import
    name: (dotted_name (identifier) @type)
    alias: (identifier) @type))

; Function calls

(decorator) @function

(call
  function: (attribute attribute: (identifier) @function.method))
(call
  function: (identifier) @function)

; Function definitions

(function_definition
  name: (identifier) @function)

; Identifier naming conventions

((identifier) @type
 (#match? @type "^[A-Z]"))

((identifier) @constant
 (#match? @constant "^_*[A-Z][A-Z\\d_]*$"))

; Builtin functions

((call
  function: (identifier) @function.builtin)
 (#match?
   @function.builtin
   "^(abs|all|any|ascii|bin|bool|breakpoint|bytearray|bytes|callable|chr|classmethod|compile|complex|delattr|dict|dir|divmod|enumerate|eval|exec|filter|float|format|frozenset|getattr|globals|hasattr|hash|help|hex|id|input|int|isinstance|issubclass|iter|len|list|locals|map|max|memoryview|min|next|object|oct|open|ord|pow|print|property|range|repr|reversed|round|set|setattr|slice|sorted|staticmethod|str|sum|super|tuple|type|vars|zip|__import__)$"))

; Literals

[
  (none)
  (true)
  (false)
] @constant.builtin

[
  (integer)
  (float)
] @number

; Self references

[
  (parameters (identifier) @variable.special)
  (attribute (identifier) @variable.special)
  (#match? @variable.special "^self$")
]

(comment) @comment
(string) @string
(escape_sequence) @escape

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

(interpolation
  "{" @punctuation.special
  "}" @punctuation.special) @embedded

; Docstrings.
(function_definition
  "async"?
  "def"
  name: (_)
  (parameters)?
  body: (block (expression_statement (string) @string.doc)))

[
  "-"
  "-="
  "!="
  "*"
  "**"
  "**="
  "*="
  "/"
  "//"
  "//="
  "/="
  "&"
  "%"
  "%="
  "^"
  "+"
  "->"
  "+="
  "<"
  "<<"
  "<="
  "<>"
  "="
  ":="
  "=="
  ">"
  ">="
  ">>"
  "|"
  "~"
  "and"
  "in"
  "is"
  "not"
  "or"
  "is not"
  "not in"
] @operator

[
  "as"
  "assert"
  "async"
  "await"
  "break"
  "class"
  "continue"
  "def"
  "del"
  "elif"
  "else"
  "except"
  "exec"
  "finally"
  "for"
  "from"
  "global"
  "if"
  "import"
  "lambda"
  "nonlocal"
  "pass"
  "print"
  "raise"
  "return"
  "try"
  "while"
  "with"
  "yield"
  "match"
  "case"
] @keyword


; snakemake


; Compound directives
[
  "rule"
  "checkpoint"
  "module"
] @keyword

; Top level directives (eg. configfile, include)
(module
  (directive
    name: _ @keyword))

; Subordinate directives (eg. input, output)
((_)
  body: (_
    (directive
      name: _ @label)))

; rule/module/checkpoint names
(rule_definition
  name: (identifier) @type)

(module_definition
  name: (identifier) @type)

(checkpoint_definition
  name: (identifier) @type)

; Rule imports
(rule_import
  "use" @keyword.import
  "rule" @keyword.import
  "from" @keyword.import
  "exclude"? @keyword.import
  "as"? @keyword.import
  "with"? @keyword.import)

; Rule inheritance
(rule_inheritance
  "use" @keyword
  "rule" @keyword
  "with" @keyword)

; Wildcard names
(wildcard (identifier) @variable)
(wildcard (flag) @variable.parameter.builtin)

; builtin variables
((identifier) @variable.builtin
  (#any-of? @variable.builtin "checkpoints" "config" "gather" "rules" "scatter" "workflow"))

; References to directive labels in wildcard interpolations
; the #any-of? queries are moved above the #has-ancestor? queries to
; short-circuit the potentially expensive tree traversal, if possible
; see:
; https://github.com/nvim-treesitter/nvim-treesitter/pull/4302#issuecomment-1685789790
; directive labels in wildcard context
((wildcard
  (identifier) @label)
  (#any-of? @label "input" "log" "output" "params" "resources" "threads" "wildcards"))

((wildcard
  (attribute
    object: (identifier) @label))
  (#any-of? @label "input" "log" "output" "params" "resources" "threads" "wildcards"))

((wildcard
  (subscript
    value: (identifier) @label))
  (#any-of? @label "input" "log" "output" "params" "resources" "threads" "wildcards"))

; directive labels in block context (eg. within 'run:')
((identifier) @label
  (#any-of? @label "input" "log" "output" "params" "resources" "threads" "wildcards")
  (#has-ancestor? @label "directive")
  (#has-ancestor? @label "block"))
