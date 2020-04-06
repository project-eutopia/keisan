# Keisan

[![Gem Version](https://badge.fury.io/rb/keisan.svg)](https://badge.fury.io/rb/keisan)
[![Build Status](https://travis-ci.org/project-eutopia/keisan.png?branch=master)](https://travis-ci.org/project-eutopia/keisan)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Hakiri](https://hakiri.io/github/project-eutopia/keisan/master.svg)](https://hakiri.io/github/project-eutopia/keisan)
[![Maintainability](https://api.codeclimate.com/v1/badges/760e213d5ea81bca4480/maintainability)](https://codeclimate.com/github/project-eutopia/keisan/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/project-eutopia/keisan/badge.svg?branch=master)](https://coveralls.io/github/project-eutopia/keisan?branch=master)

Keisan ([計算, to calculate](https://en.wiktionary.org/wiki/%E8%A8%88%E7%AE%97#Japanese)) is a Ruby library for parsing equations into an abstract syntax tree.
This allows for safe evaluation of string representations of mathematical/logical expressions.
It has support for variables, functions, conditionals, and loops, making it a [Turing complete](https://github.com/project-eutopia/keisan/blob/master/spec/keisan/turing_machine_spec.rb) programming language.

## Installation

Add this line to your application's Gemfile:

```
gem 'keisan'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keisan

## Usage

### REPL

To try `keisan` out locally, clone this repository and run the executable `bin/keisan` to open up an interactive REPL.
The commands you type in to this REPL are relayed to an internal `Keisan::Calculator` class and displayed back to you.

![alt text](screenshots/repl.png "Keisan built-in REPL")


### Calculator class

This library is interacted with primarily through the `Keisan::Calculator` class.
The `evaluate` method evaluates an expression by parsing it into an abstract syntax tree (AST), and evaluating it.
There is also a `simplify` method that allows undefined variables and functions to exist, and will just return the simplified AST.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("15 + 2 * (1 + 3)")
#=> 23
calculator.simplify("1*(0*2+x*g(t))").to_s
#=> "x*g(t)"
```

For users who want access to the parsed abstract syntax tree, you can use the `ast` method to parse any given expression.

```ruby
calculator = Keisan::Calculator.new
ast = calculator.ast("x**2+1")
ast.class
#=> Keisan::AST::Plus
ast.to_s
#=> "(x**2)+1"
ast.children.map(&:to_s)
#=> ["x**2", "1"]
```

##### Specifying variables

Passing in a hash of variable (`name`, `value`) pairs to the `evaluate` method is one way of defining variables

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("3*x + y**2", x: -2.5, y: 3)
#=> 1.5
```

It is also possible to define variables in the string expression itself using the assignment `=` operator

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("x = 10*n", n: 2)
calculator.evaluate("3*x + 1")
#=> 61
```


##### Specifying functions

Just like variables, functions can be defined by passing a `Proc` object as follows

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("2*f(1+2) + 4", f: Proc.new {|x| x**2})
#=> 22
```

Note that functions work in both regular (`f(x)`) and postfix (`x.f()`) notation, where for example `a.f(b,c)` is translated internally to `f(a,b,c)`.
The postfix notation requires the function to take at least one argument, and if there is only one argument to the function then the braces can be left off: `x.f`.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("[1,3,5,7].size")
#=> 4
calculator.define_function!("f", Proc.new {|x| [[x-1,x+1], [x-2,x,x+2]]})
calculator.evaluate("4.f[0]")
#=> [3,5]
calculator.evaluate("4.f[1].size")
#=> 3
```

Like variables, it is also possible to define functions in the string expression itself using the assignment operator `=`

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("f(x) = n*x", n: 10) # n is local to this definition only
calculator.evaluate("f(3)")
#=> 30
calculator.evaluate("f(0-a)", a: 2)
#=> -20
calculator.evaluate("n") # n only exists in the definition of f(x)
#=> Keisan::Exceptions::UndefinedVariableError: n
calculator.evaluate("includes(a, element) = a.reduce(false, found, x, found || (x == element))")
calculator.evaluate("[3, 9].map(x, [1, 3, 5].includes(x))").value
#=> [true, false]
```

This form even supports recursion, but you must explicitly allow it.

```ruby
calculator = Keisan::Calculator.new
calculator = Keisan::Calculator.new(allow_recursive: false)
calculator.evaluate("my_fact(n) = if (n > 1, n*my_fact(n-1), 1)")
#=> Keisan::Exceptions::InvalidExpression: Unbound function definitions are not allowed by current context

calculator = Keisan::Calculator.new(allow_recursive: true)
calculator.evaluate("my_fact(n) = if (n > 1, n*my_fact(n-1), 1)")
calculator.evaluate("my_fact(4)")
#=> 24
calculator.evaluate("my_fact(5)")
#=> 120
```

##### Multiple lines and blocks

Keisan understands strings which contain multiple lines.
It will evaluate each line separately, and the last line will be the the result of the total evaluation.
Lines can be separated by newlines or semi-colons.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("x = 2; y = 5\n x+y")
#=> 7
```

The use of curly braces `{}` can be used to create block which has a new closure where variable definitions are local to the block itself.
Inside a block, external variables are still visible and re-assignable, but new variable definitions remain local.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("x = 10; y = 20")
calculator.evaluate("{a = 100; x = 15; a+x+y}")
#=> 135
calculator.evaluate("x")
#=> 15
calculator.evaluate("a")
#=> Keisan::Exceptions::UndefinedVariableError: a
```

By default assigning to a variable or function will bubble up to the first definition available in the parent scopes.
To assign to a local variable instead of modifying an existing variable out of the closure, you can use the `let` keyword.
The difference is illustrated below.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("x = 1; {x = 2}; x")
#=> 2
calculator.evaluate("x = 11; {let x = 12}; x")
#=> 11
```

##### Lists

Just like in Ruby, lists can be defined using square brackets, and indexed using square brackets

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("[2, 3, 5, 8]")
#=> [2, 3, 5, 8]
calculator.evaluate("[[1,2,3],[4,5,6],[7,8,9]][1][2]")
#=> 6
calculator.evaluate("a = [1,2,3]")
calculator.evaluate("a[1] += 10*a[2]")
calculator.evaluate("a")
#=> [1, 32, 3]
```

They can also be concatenated using the `+` operator

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("[3, 5] + [x, x+1]", x: 10)
#=> [3, 5, 10, 11]
```

Keisan also supports the following useful list methods,

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("[1,3,5].size")
#=> 3
calculator.evaluate("[1,3,5].max")
#=> 5
calculator.evaluate("[1,3,5].min")
#=> 1
calculator.evaluate("[1,3,5].reverse")
#=> [5,3,1]
calculator.evaluate("[[1,2],[3,4]].flatten")
#=> [1,2,3,4]
calculator.evaluate("range(5)")
#=> [0,1,2,3,4]
calculator.evaluate("range(5,10)")
#=> [5,6,7,8,9]
calculator.evaluate("range(0,10,2)")
#=> [0,2,4,6,8]
```

##### Hashes

Keisan also supports associative arrays (hashes), which maps keys to values.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("my_hash = {777: 3*4, \"bar\": \"hello world\"}")
calculator.evaluate("my_hash[777]")
#=> 12
calculator.evaluate("s = 'ba'")
calculator.evaluate("my_hash[s + 'r']")
#=> "hello world"
calculator.evaluate("my_hash['baz']")
#=> nil
calculator.evaluate("my_hash['baz'] = 999")
calculator.evaluate("my_hash['baz']")
#=> 999
```

There is also a `to_h` method which converts a list of key value pairs into a hash.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("range(1, 6).map(x, [x, x**2]).to_h")
#=> {1 => 1, 2 => 4, 3 => 9, 4 => 16, 5 => 25}
```

##### Date and time objects

Keisan supports date and time objects like in Ruby.
You create a date object using either the method `date` (either a string to be parsed, or year, month, day numerical arguments) or `today`.
They support methods `year`, `month`, `day`, `weekday`, `strftime`, and `to_time` to convert to a time object.
`epoch_days` computes the number of days since Unix epoch (Jan 1, 1970).

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("x = 11")
calculator.evaluate("(5 + date(2018, x, 2*x)).day")
#=> 27
calculator.evaluate("today() > date(2018, 11, 1)")
#=> true
calculator.evaluate("date('1999-12-31').to_time + 10")
#=> Time.new(1999, 12, 31, 0, 0, 10)
calculator.evaluate("date(1970, 1, 15).epoch_days")
#=> 14
```

Time objects are created using `time` (either a string to be parsed, or year, month, day, hour, minute, second arguments) or `now`.
They support methods `year`, `month`, `day`, `hour`, `minute`, `second`, `weekday`, `strftime`, and `to_date` to convert to a date object.
`epoch_seconds` computes the number of seconds since Unix epoch (00:00:00 on Jan 1, 1970).

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("time(2018, 11, 22, 12, 0, 0).to_date <= date(2018, 11, 22)")
#=> true
calculator.evaluate("time('2000-4-15 12:34:56').minute")
#=> 34
calculator.evaluate("time('5000-10-10 20:30:40').strftime('%b %d, %Y')")
#=> "Oct 10, 5000"
calculator.evaluate("time(1970, 1, 1, 2, 3, 4).epoch_seconds")
#=> 7384
```

##### Functional programming methods

Keisan also supports the basic functional programming operators `map` (or `collect`), `filter` (or `select`), and `reduce` (or `inject`).

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("map([1,3,5], x, 2*x)")
#=> [2,6,10]
calculator.simplify("{'a': 1, 'b': 3, 'c': 5}.collect(k, v, y*v**2)").to_s
#=> "[y,9*y,25*y]"

calculator.evaluate("[1,2,3,4].select(x, x % 2 == 0)")
#=> [2,4]
calculator.evaluate("filter({'a': 1, 'bb': 4, 'ccc': 9}, k, v, k.size == 2)")
#=> {"bb" => 4}

calculator.evaluate("[1,2,3,4,5].inject(1, total, x, total*x)")
#=> 120
calculator.evaluate("{'foo': 'hello', 'bar': ' world'}.reduce('', res, k, v, res + v)")
#=> "hello world"
```

##### Logical operations

`keisan` understands basic boolean logic operators, like `<`, `<=`, `>`, `>=`, `&&`, `||`, `!`, so calculations like the following are possible

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("1 > 0")
#=> true
calculator.evaluate("!!!true")
#=> false
calculator.evaluate("x >= 0 && x < 10", x: 5)
#=> true
```

There is also a useful ternary `if` function defined

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("2 + if(1 > 0, 10, 29)")
#=> 12
```

For looping, you can use the basic `while` loop, which has an expression that evaluates to a boolean as the first argument, and any expression in the second argument.
One can use the keywords `break` and `continue` to control loop flow as well.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("my_sum(a) = {let i = 0; let total = 0; while(i < a.size, {total += a[i]; i += 1}); total}")
calculator.evaluate("my_sum([1,3,5,7,9])")
#=> 25
calculator.evaluate("has_element(a, x) = {let i=0; let found=false; while(i<a.size, if(a[i] == x, found = true; break); i+=1); found}")
calculator.evaluate("[2, 3, 7, 11].has_element(11)")
#=> true
```

##### Bitwise operations

The basic bitwise operations, NOT `~`, OR `|`, XOR `^`, AND `&`, and left/right bitwise shifts (`<<` and `>>`) are also available for use

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("0b00001111 & 0b10101010")
#=> 10
```

##### String

`keisan` also can parse in strings, and access the characters by index

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("'hello'[1]")
#=> "e"
```

##### Binary, octal, and hexadecimal numbers

Using the prefixes `0b`, `0o`, and `0x` (standard in Ruby) indicates binary, octal, and hexadecimal numbers respectively.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("0b1100")
#=> 12
calculator.evaluate("0o775")
#=> 509
calculator.evaluate("0x1f0")
#=> 496
```

##### Random numbers

`keisan` has a couple methods for doing random operations, `rand` and `sample`.  For example,

```ruby
calculator = Keisan::Calculator.new
(0...10).include? calculator.evaluate("rand(10)")
#=> true
[2,4,6,8].include? calculator.evaluate("sample([2, 4, 6, 8])")
#=> true
```

If you want reproducibility, you can pass in your own `Random` object to the calculator's context.

```ruby
calculator1 = Keisan::Calculator.new(context: Keisan::Context.new(random: Random.new(1234)))
calculator2 = Keisan::Calculator.new(context: Keisan::Context.new(random: Random.new(1234)))
5.times.map {calculator1.evaluate("rand(1000)")}
#=> [815, 723, 294, 53, 204]
5.times.map {calculator2.evaluate("rand(1000)")}
#=> [815, 723, 294, 53, 204]
```

##### Builtin variables and functions

`keisan` includes all standard methods given by the Ruby `Math` class.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("log10(1000)")
#=> 3.0
```

Furthermore, the constants `PI`, `E`, `I`, and `INF` are included.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("E**(I*PI)+1")
#=> (0.0+0.0i)
```

There is a `replace` method that can replace instances of a variable in an expression with another expression.  The form is `replace(original_expression, variable_to_replace, replacement_expression)`.  Before the replacement is carried out, the `original_expression` and `replacement_expression` are `evaluate`d, then instances in the original expression of the given variable are replaced by the replacement expression.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("replace(x**2, x, 3)")
#=> 9
```

When using `Calculator` class, all variables must be replaced before an expression can be calculated, but the ability to replace any expression is useful when working directly with the AST.

```ruby
ast = Keisan::AST.parse("replace(replace(x**2 + y**2, x, sin(theta)), y, cos(theta))")
ast.evaluate.to_s
#=> "(sin(theta)**2)+(cos(theta)**2)"
```

The derivative operation is also builtin to Keisan as the `diff` function.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("diff(4*x, x)")
#=> 4
calculator.evaluate("replace(diff(4*x**2, x), x, 3)")
#=> 24
```

This also works intelligently with user defined functions.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("f(x, y) = x**2 + y")
calculator.simplify("diff(f(2*t, t+1), t)").to_s
#=> "1+(8*t)"
calculator.evaluate("replace(diff(f(2*t, t+1), t), t, 3)")
#=> 1+8*3
```

There is also a `puts` function that can be used to output the result of an expression to STDOUT.

```ruby
calculator = Keisan::Calculator.new
calculator.evaluate("x = 5")
calculator.evaluate("puts x**2") # prints "25\n" to STDOUT
```


## Supported elements/operators

`keisan` supports the following operators and elements.

#### Numbers, variables, brackets, functions, lists, hashes
- `150`, `-5.67`, `6e-5`: regular numbers
- `x`, `_myvar1`: variables
- `(` and `)`: round brackets for grouping parts to evaluate first
- `f(x,y,z)`, `my_function(max([2.5, 5.5]))`, `[2,4,6,8].size`: functions using `(` `)` brackets (optional if using postfix notation and only takes a single argument)
- `[0, 3, 6, 9]`: square brackets with comma separated values to denote lists
- `{'foo': 11, 'bar': 22}`: curly brackets containing key/value pairs creates a hash

#### Arithmetic operators
- `+`, `-`, `*`, `/`: regular arithmetic operators
- `**`: Ruby style exponent notation (to avoid conflict with bitwise xor `^`)
- `%`: Ruby modulo operator, sign of `a % b` is same as sign of `b`
- `+`, `-`: Unary plus and minus

#### Logical operators
- `<`, `>`, `<=`, `>=`: comparison operators
- `==` and `!=`: logical equality check operators
- `&&` and `||`: logical operators, **and** and **or**
- `!`: unary logical not

#### Bitwise operators
- `&`, `|`, `^`: bitwise **and**, **or**, **xor** operators
- `<<`, `>>` bitwise shift operators
- `~`: unary bitwise not

#### Indexing of arrays/hashes
- `list[i]`: for accessing elements in an array
- `hash[k]`: for accessing elements in a hash

#### Assignment
- `=`: can be used to define variables and functions
- `+=`: can be used in combination with operators above


## Development

After checking out the repository, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment with the library pre-loaded.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/project-eutopia/keisan.
If there is any functionality you would like (e.g. new functions), feel free to open a [new issue](https://github.com/project-eutopia/keisan/issues/new).
