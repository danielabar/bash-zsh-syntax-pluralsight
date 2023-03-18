<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Bash and Zsh Scripting Syntax](#bash-and-zsh-scripting-syntax)
  - [Working with Shell Syntax](#working-with-shell-syntax)
  - [Working with Variables](#working-with-variables)
    - [Understanding Variables](#understanding-variables)
    - [Working with Variable Scope](#working-with-variable-scope)
    - [Understand the Power of Declare](#understand-the-power-of-declare)
    - [Understanding Special Variable Cases](#understanding-special-variable-cases)
  - [Creating Conditional Statements](#creating-conditional-statements)
    - [Understanding Simple Tests](#understanding-simple-tests)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Bash and Zsh Scripting Syntax

My notes from Pluralsight [course](https://app.pluralsight.com/library/courses/mastering-bash-z-shell-scripting-syntax/table-of-contents).

## Working with Shell Syntax

Zsh released in 1990, Bash released in 1989.

Can use syntax in script files or directly from the command line. But placing it in script makes it re-usable.

## Working with Variables

### Understanding Variables

Scope of a variable defines its boundaries, scope could be:
1. Local (just setting)
2. Environment (using export command)
3. Command (only effective to one instance of command)

**Local Variable**

* local to shell - available to shell, but not by commands launched from it
* Ubuntu defaults to nano text editor, use `EDITOR` variable to adjust
* local variable will not affect other commands eg `crontab`, which will still open in default `nano` editor

```bash
sudo apt install vim
# set a local variable
EDITOR=vim
# will still open in nano
crontab -e
```

**Environment Variable**

Configuring an env var makes it available to `crontab` and other commands.

```bash
export EDITOR=vim
# this time will open in vim
crontab -e
# do some other things
# calling crontab again will still open in vim due to use of env var which is permanent
crontab -e
```

**Command Variable**

* Use if don't want to set variable permanently like env var.
* Use command scope for variable that only needs to be in effect for single instance of a command execution.
* This kind of variable does not persist after execution.

```bash
# will open in vim because EDITOR variable is using command scope so it affects the currently executing command
EDITOR=vim crontab -e
# do some other things
# opening crontab again will open in nano, because the EDITOR var set earlier was only command scope
crontab -e
```

### Working with Variable Scope

```bash
# set a local variable
EDITOR=vim

# verify its set using the `set` command and piping through `grep`
set | grep "EDITOR"
# outputs: EDITOR=vim

# exporting it makes it an env var
# no need to set it again because its already set
export EDITOR

# verify its set as an env var using `env` command and piping through `grep`
env | grep "EDITOR"
# outputs: EDITOR=vim

# use `unset` to undo the env var setting
unset EDITOR
# now both `set | grep "EDITOR"` and `env | grep "EDITOR"` return no output
```

Note that `!!` repeats previous command.

### Understand the Power of Declare

`declare` is a shell built-in to manage variables.

**Printing Variables**

`set` lists variables, `env` lists env vars, `declare` lists both.

```bash
# set a local var
MYVAR=pluralsight

# display it with `set` command
set | grep MYVAR
# outputs: MYVAR=pluralsight

# configure an env var and set its value in a single line
export MYENV=utah

# display it with `env` command
env | grep MYENV
# outputs: MYENV=utah

# use `declare -p` to print variables, limiting the output to only those we want to see
declare -p MYVAR MYENV
# outputs:
# typeset MYVAR=pluralsight
# export MYENV=utah
```

**Converting Case**

`declare` command has `-u` and `-l` options to control the case of the value being set.

```bash
# set a variable providing mixed case, but `-l` supposed to lower case it
declare -l fruit=Apple

# print the value
declare -p fruit
# outputs: typeset -l fruit=Apple
# lower case option doesn't seem to work on mac?
# but echo does show it in the expected case
echo $fruit
# apple

# clear the variable
unset fruit
declare -p fruit
# delcare: no such variable: fruit

# set in upper case
declare -u fruit=Apple
declare -p fruit
echo $fruit
# APPLE
```

**Demo**

`declare -p` will list *all* variables.

`declare -p MYVAR` will only list the value of `MYVAR` variable.

`declare -x MYVAR` exports the variable.

```bash
FOO=vim
declare -x FOO
env | grep FOO
# FOO=vim
```

`declare +x MYVAR` removes environment variable.

Can combine options, eg `declare -xl FOO` makes `FOO` an env var *and* makes its value lower case:

```bash
# populate a local variable as mixed case
FOO=Vim
# use declare to export the variable and convert value to lower case
declare -xl FOO
env | grep FOO
# FOO=vim

# give the variable a different mixed case value
FOO=naNO
env | grep FOO
# the new value has been converted to lower case because of `declare -xl FOO` used earlier
# FOO=nano
```

### Understanding Special Variable Cases

**Constant**

* `declare -r` command can also be used to create constants, aka readonly variables.
* readonly vars cannot be unset and remain in effect for duration of shell session.
* adds security, eg: set a value in a system login script that users can't change.

```shell
# declare a readonly variable
declare -r name=bob
unset name
# zsh: read-only variable: name
name=fred
# zsh: read-only variable: name

# remove read-only status
declare +r name
name=fred
echo $name
# fred
```

**Integer**

* By default, variables accept string values.
* Can populate a variable with an integer, but later it could be set with a string.
* `declare -i` forces the data-type to always be an integer.

```bash
declare -i days=30
declare -p days
# typeset -i days=30
echo $days
# 30

days=Monday
echo $days
# 0
```

**Arrays**

So far have only looked at scalar/single-value variables.

Arrays are multi-value, can be indexed (0-based) or associative arrays (using key-value pairs).

Actually: zsh on Mac, arrays are 1-based!

```bash
# declare an indexed array
declare -a user_name
user_name[1]=bob ; user_name[2]=smith
echo $user_name
# bob smith
echo ${user_name[1]}
# bob
echo ${user_name[2]}
# smith
echo ${user_name[@]}
# bob smith (i.e. outputs all values in the array starting from first index position to last)


# unset the user_name array and declare it again as an associative array
unset user_name ; declare -A user_name
# confirm what kind of var user_name is
declare -p user_name
# outputs: typeset -A user_name=( )

# populate associate array with key/value pairs - here we populate multiple key/value pairs at once:
user_name=([first]=bob [last]=smith)

# could also populate key/values one at a time:
user_name[first]=bob
user_name[last]=smith

# inspect the values by key
echo ${user_name[first]}
# bob
echo ${user_name[last]}
# smith

# list all values - output will be in however its stored
echo ${user_name[@]}
# smith bob

# show keys and values
declare -p user_name
# typeset -A user_name=( [first]=bob [last]=smith )
```

## Creating Conditional Statements

### Understanding Simple Tests

Double vertical bar `||` is for OR statement. Second command only runs if first fails:

```shell
echo hello || echo bye
# hello
```

Double ampersand `&&` is for AND statement. Second command executes only if first command succeeds:

```shell
echo hello && echo bye
# hello
# bye
```

If statement `if...fi` has at least one condition to test, followed by one or more actions. Notice the condition is in square brackets. Notice the spaces within the square brackets:

```shell
declare -i days=30
if [ $days -lt 1 ] ;then echo "days must be greater than one"; fi
# no output

# Recall that populating an integer variable with a string will set it to 0
declare -i days=Monday
if [ $days -lt 1 ] ;then echo "days must be greater than one"; fi
# days must be greater than one
```

Extending test with AND/OR - example want to enforce that `days` variable cannot be less than 1 or greater than 30. Notice the OR is outside of the square brackets:

```shell
declare -i days=31

if [ $days -lt 1 ] || [ $days -gt 30 ]; then
  echo "days must be between 1 and 30 inclusive"
fi
# outputs: days must be between 1 and 30 inclusive
```

Note from ChatGPT about single vs double square brackets for conditionals:

The double square brackets `[[ ... ]]` are a special syntax used for conditional expressions in the Bash shell and other POSIX-compliant shells like Zsh.

Double square brackets are more powerful than single square brackets because they provide additional features such as regular expression matching, pattern matching, and support for more operators. They also have a more consistent and reliable behavior in edge cases, such as when dealing with empty variables or variables containing whitespace.

**Arithmetic Evaluation**

Newer bash/zsh shells support advanced syntax for arithmetic evaluation, allowing simple notation and combining OR within the test. `$` can be omitted for variable name. Notice the double round brackets instead of square brackets. Still need spaces within the parens, notice the OR occurs within the round brackets:

```shell
declare -i days=31

# This syntax is more legible
if (( days < 1 || days > 30 )); then
  echo "days must be between 1 and 30 inclusive"
fi
# outputs: days must be between 1 and 30 inclusive
```

**Else**

Using "else" supports performing some action both on correct and incorrect input.

```shell
declare -i days=30

if (( days < 1 || days > 30 )); then
  echo "days must be between 1 and 30 inclusive";
else
  echo "days is good";
fi
# outputs: days is good
```

**Elif**

Use `elif` (i.e. else if...) when need to test more than one condition.

Can also use the command `read` to populate a variable, useful for getting input from a script.

```shell
declare -i days
read days
# Input at prompt: Monday

if (( days < 1)); then
  echo "Enter a number";
elif (( days > 30 )); then
  echo "Too high";
else
  echo "The value is $days";
fi
```
