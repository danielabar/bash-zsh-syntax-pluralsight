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
    - [Working with Simple Tests and Arithmetic Expressions](#working-with-simple-tests-and-arithmetic-expressions)
    - [Testing Strings and Regular Expressions](#testing-strings-and-regular-expressions)
    - [Understanding File Attributes](#understanding-file-attributes)
      - [Demo](#demo)
    - [Creating Scripts with Test Conditions](#creating-scripts-with-test-conditions)
    - [Working with the Case Statement](#working-with-the-case-statement)
    - [Summary](#summary)
  - [Building Effective Functions](#building-effective-functions)
    - [Exporting Functions](#exporting-functions)
    - [Working with Arguments and Returns](#working-with-arguments-and-returns)
    - [Best Practices](#best-practices)
    - [Summary](#summary-1)
  - [Understanding Shell Iteration Using Loops](#understanding-shell-iteration-using-loops)
    - [Introducing While and Until Loops](#introducing-while-and-until-loops)
    - [Understanding For Loops](#understanding-for-loops)

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

### Working with Simple Tests and Arithmetic Expressions

Need to understand what's returned from commands, eg:

```shell
cat /etc/hosts
echo $?
# 0
cat /etc/hostss
echo $?
# 1
```

`0` means the last command executed has succeeded, non-zero means command has failed, eg: trying to list contents of a non-existent file.

Create a new user only if user doesn't already exist in the password file:

```shell
getent passwod tux1 || sudo useradd tux1
```

Only set password for user `tux1` if can successfully retrieve user from password file:

```shell
getent passwod tux1 && sudo passwod tux1
# prompts for password
```

**Simple IF Statements**


```shell
# Declare an integer variable but do not assign it a value
declare -i days
# Prompt user to enter a value
read days
# enter 30
if [ $days -lt 1 ] ; then echo "Enter a correct value" ; fi
```

**Arithmetic Evaluation**

Using square brackets for conditionals is old POSIX syntax. There's a better way for more modern shells using double parens. Can remove `$` from variable, and use `<` instead of `-lt`. Can also combine multiple conditions:

```shell
if (( days <  1 || days > 30 )) ; then echo "Enter a correct value" ; fi
```

**NOTE: History Expansion**

Can re-run the `read` command with `!r`. Explanation from ChatGPT:

In a Unix shell, the "!" character followed by a command or string is used to invoke history expansion, which allows you to refer to previous commands in your command history.

Specifically, the "!" character followed by a command or string is used as a history substitution event designator. When entered at the beginning of a command line, it tells the shell to perform history expansion and replace the "!" character followed by a command or string with the corresponding command from the command history.

For example, you can use "!ls" to repeat the last executed command that started with "ls". If you have executed multiple "ls" commands in the past, the most recent one will be repeated. Similarly, you can use "!42" to repeat the 42nd command in your command history.

You can also use various modifiers with "!" to modify the behavior of history expansion, such as "!:n" to refer to the nth argument of the previous command, "!$ " to refer to the last argument of the previous command, and so on.

It's important to note that history expansion using "!" is a powerful feature, but it can also be potentially risky, as it can execute commands from your command history without explicit confirmation. Therefore, it's important to be cautious when using "!" and double-check the command that will be executed before proceeding.

**Elif and Else**

Update to display different messages

```shell
if (( days <  1 )) ; then echo "Enter a numeric value" ; elif (( days > 30 )) ; then echo "Enter a value less than 31" ; else echo "The days are $days" ; fi
```

### Testing Strings and Regular Expressions

Prefer `==` over `=` for testing string equality to differentiate from assignment operator.

`!=` for not equals.

`=~` for regex matching.

```shell
# declare a lower cased variable
declare -l user_name
read user_name
# populate with mixed case: Bob
[ $user_name == 'bob' ] && echo "user is bob"
# user is bob
[ $user_name == 'Bob' ] && echo "user is bob"
# no output
echo $?
# 1 (because previous test of string equality failed)

read user_name
# populate with: alice

# test for inequality
[ $user_name != 'alice' ]
echo $?
# 1
```

**Testing Partial String Values**

Use double square bracket syntax `[[...]]` in advanced shells to test for partial values. `$` is required for variable.

```shell
declare -l browser
read browser
# enter at the prompt: Firefox

# Test if `browser` variable ends in `fox`
[[ $browser == *fox ]] && echo "The browser is Firefox"
# Outputs: The browser is Firefox

# Test if it starts with `fire` - answer is no because its case sensitive
[[ $browser == fire* ]] && echo "The browser is Firefox"
# No output (return code 1)

# Test if it starts with `Fire` - yes!
[[ $browser == Fire* ]] && echo "The browser is Firefox"
# Outputs: The browser is Firefox
```

Another example: Suppose have usernames like `bob_user` for regular user and `bob_admin` for admins. Want to test if a given username is an admin:

```shell
declare -l user_name
read user_name
# Enter: bob_admin

# Is it an admin?
[[ $user_name == *_admin ]]
echo $?
# 0

# Is it a regular user?
[[ $user_name == *_admin ]]
echo $?
# 1
```

**Testing Regular Expressions**

Regex testing is a more expressive way of searching for strings.

Use double square bracket syntax and match operator `=~`. Result is stored in array `BASH_REMATCH`.

NOTE:  To use `BASH_REMATCH` on Mac, first need to run `setopt BASH_REMATCH`

```shell
declare -l test_var
read test_var
# Enter at prompt: color

[[ $test_var =~ colou?r ]] && echo "${BASH_REMATCH[0]}"
```

But this does work:

```shell
#!/bin/zsh

# Declare variable in lowercase
typeset -l test_var

# Set a value for test_var
test_var="color"

# Perform regular expression matching: Look for American or Canadian/UK spelling
# `?` following the letter `u` makes it optional
if [[ $test_var =~ 'colou?r' ]]; then
  # Extract captured substring
  match=$MATCH
  echo "Match: $match"
else
  echo "No match found."
fi
```

Admin vs regular user example:

```shell
declare -l user_name
read user_name
# Enter: bob_admin

# Use regex to test if username ends in `_admin`, use `$` as anchor for end of string
[[ $user_name =~ _admin$ ]]
echo $?
# 0

# Is it regular user?
[[ $user_name =~ _user$ ]]
echo $?
# 1

# Inspect the match
echo $BASH_REMATCH[1]
```

### Understanding File Attributes

**The Test Command**

`[` is a synonym for test.

`[[` is for advanced test that should be used in precedence to `[`, and is a shell keyword.

There is also a `test` command that is a shell builtin.

**Builtin vs Keyword:**

From ChatGPT:

Shell Builtin:
A shell builtin is a command or function that is built into the shell itself. It is implemented as part of the shell's executable code and is directly executed by the shell without invoking an external program. This means that the builtin commands are executed within the same process as the shell itself, without creating a separate process. Examples of shell builtins include commands like cd for changing directories, echo for displaying messages, and export for setting environment variables. Because they are part of the shell, builtins can directly manipulate the shell's internal state, such as modifying shell variables, and can have a more direct impact on the shell's behavior.

Shell Keyword:
A shell keyword, on the other hand, is a reserved word recognized by the shell as a special instruction, but it is not part of the shell's built-in commands. Keywords are interpreted by the shell itself and are not executed as separate processes. Keywords are typically used to define control structures like loops and conditionals, and they are used in shell scripts to implement complex logic. Examples of shell keywords include if, else, while, and for.

The main difference between a shell builtin and a shell keyword is that builtins are commands that are part of the shell's internal code and are executed directly by the shell, while keywords are reserved words recognized by the shell for implementing control structures in shell scripts. Builtins are typically used for performing operations that require direct manipulation of the shell's state, while keywords are used for controlling the flow of execution in shell scripts.

**Testing file Attributes**

Example: Check if a file is a regular file with `-f`

```shell
# Using test command
test -f /etc/hosts && echo YES
# YES

# Using advanced test
[[ -f /etc/hosts ]] && echo YES
# YES

# test for directory
[[ -d /etc ]] && echo IS_DIR
# IS_DIR

# test for symbolic link
[[ -L /etc/localtime ]]
# IS_LINK

# test for existence of a file, no matter the type
[[ -e /etc/nolgin ]]

# test for read permission (r), write (w), execute (x)
[[ -r /etc/hosts ]]

# test for sticky bit
[[ -k /tmp ]]

# tests for the SUID bit (use g for the GUID bit)
[[ -s /bin/passwd ]]
```

**NOTE: Sticky bit explanation from ChatGPT:**

The sticky bit is a special permission bit that can be set on directories to modify their behavior.
When the sticky bit is set on a directory, it restricts the deletion or renaming of files within that directory to only the owner of the file, the owner of the directory, or the superuser (root). This means that even if other users have write permissions on the directory, they cannot delete or rename files owned by other users within that directory.

The sticky bit is represented by the letter "t" in the permissions field of a directory when viewed with the "ls" command. To set the sticky bit on a directory, you can use the "chmod" command with the "+t" option, followed by the name of the directory

**NOTE: SUID bit explanation from ChatGPT:**

The SUID (Set User ID) bit is a special permission bit in Linux and Unix-like operating systems that can be set on executable files. When the SUID bit is set on an executable file, it changes the way the file is executed and determines the user's privileges while running the file.

Specifically, when an executable file has the SUID bit set, it is executed with the permissions of the file's owner instead of the permissions of the user who is executing the file. This means that if a user executes an executable file with the SUID bit set, the file runs with the permissions of the owner of the file, allowing the user to perform actions that would normally require higher privileges.

The SUID bit is represented by the letter "s" in the permissions field of a file when viewed with the "ls" command.

**type command**

Shows whether the given command is a built-in, alias, function, or external binary.

```bash
type test [
# test is a shell builtin
# [ is a shell builtin
```

#### Demo

```shell
# if `dir1` does not exist, go ahead and create it
test -e dir1 || mkdir dir1

# make sure user has write permission to dir1 and if yes, make a file in that directory
test -w dir1 && touch dir1/file1
```

### Creating Scripts with Test Conditions

Example:

```bash
#!/bin/zsh

declare -l DIR
# Use -n with echo so it will not generate new line char,
# This way when user enters their value, its on the same line as the prompt
echo -n "Enter the name of the directory to create: "
read DIR

# check if a file or dir named $DIR already exists
if [[ -e $DIR ]]; then
  echo "A file or directory already exists with the name $DIR"
  exit 1
else
  # check that the user has permission to write to the current working directory
  if [[ -w $PWD ]]; then
    # if entered `FOO` at prompt, this will create a dir named `foo`
    echo "Creating directory $DIR"
    mkdir $DIR
  else
    echo "You don't have write permission to create $DIR within $PWD"
    exit 2
  fi
fi
```

Note using two different exit codes to distinguish the two different error conditions.


```bash
# Make the script executable:
chmod +x scripts/test-conditions.sh

# Run it in the current project dir:
./scripts/test-conditions.sh

# Run it somewhere you don't have write permissions
cd /etc
/path/to/scripts/test-conditions.sh
```

### Working with the Case Statement

More efficient than having many `elif` statements. The script parser can read the test condition just once. Starts with `case` and ends with `esac`. Each block ends with `;;`.

```bash
case $USER in
  tux )
    echo "You are the course instructor"
    ;;
  dbaron )
    echo "You are a course participant"
    ;;
  root )
    echo "You are the boss"
    ;;
esac
```

Another example - note that the double semi-colon `;;` can also be on the same line as the command that gets executed when the specific case matches:

```bash
#!/bin/zsh

# short form of current month, eg: `Apr`, then lower case it, eg: `apr`
# declare and populate in the same line
# note that $(...) executes a subshell and returns output of the command inside it, aka command substitution
declare -l month=$(date +%b)

# output what season it is based on the current month
case $month in
  dec | jan | feb )
    echo "Winter";;
  mar | apr | may )
    echo "Spring";;
  jun | jul | aug )
    echo "Summer";;
  sep | oct | nov )
    echo "Winter";;
esac
```

**Common Date Format Codes**

* `%Y` 4-digit year
* `%m` 2-digit month (with leading zeros)
* `%d` 2-digit day of the month (with leading zeros)
* `%H` 2-digit hour in 24-hour format (with leading zeros)
* `%M` 2-digit minute (with leading zeros)
* `%S` 2-digit second (with leading zeros)
* `%A` Full weekday name (e.g. Sunday)
* `%a` Abbreviated weekday name (e.g. Sun)
* `%B` Full month name (e.g. January)
* `%b` Abbreviated month name (e.g. Jan)
* `%j` Day of the year (e.g. 001 for January 1st)
* `%U` Week number of the year, with Sunday as the first day of the week
* `%u` Week number of the year, with Monday as the first day of the week

You can combine these format codes to create custom date and time formats, such as `date +%Y-%m-%d` to get the current date in YYYY-MM-DD format.

### Summary

AND condition represented with `&&`, OR condition represented with `||`

To build more complex flows, use: `if condition ; then action ; fi`

In advanced shells (bash, zsh), use double parens for arithmetic calculations: `(( days < 1 ))`

Combine AND/OR into conditional tests: `(( days < 1 || days > 30 ))`

In advanced shell, can also use double square brackets to test for strings: `[[ $month == jan ]]`

Can also test for partial strings: `[[ $month == j* ]]`

Not equals: `[[ $month != jan ]]`

Use match operator for regex, eg: does the given month end in `y`: `[[ $month =~ y$ ]]`

General form of case statement: `case $VAR in; some_val ); some_action;; esac`

## Building Effective Functions

Functions are local to the shell they're defined in. If want it available to sub-shells, need to `export`.

Functions exist in memory, they execute from the memory of the shell.

Shell functions encapsulate blocks of code in named elements that can be executed or called from scripts or directly via CLI.

Round parents `()` indicate the function can accept arguments, but for this simple example, we're not using any args:

**Simple Example**

```bash
# declare a function named say_hello
function say_hello () {
  echo hello
}

# execute the function at CLI
say_hello
# outputs: hello
```

**List Functions**

Lowercase `-f` prints details of functions, uppercase `-F` prints the function names (upper case doesn't work on Mac).

```bash
# list all functions and their details
declare -f

# list just a single funciton
declare -f say_hello
# say_hello () {
#   echo hello
# }
```

Can name a function whatever you want as long as its not already in use. Can define a function at prompt:

```bash
$ function say_hello() {
function> echo hello
function> }
$
$ say_hello
$ # outputs: hello
```

You can pass args but are silently ignored:

```bash
$ say_hello foo
$ # outputs: hello
```

### Exporting Functions

To make a function available to a subshell, needs to be exported, similar to variables.

Carrying on with `say_hello` example function declared previously, if launch a subshell, the function is not available, but if export it, it is available to subshell. NOTE: This didn't work on Mac.

```bash
# open a subshell
bash

# try to run say_hello
say_hello
# command not found: say_hello

# exit the subshell
exit

# export the say_hello function, indicate that it is a function
declare -xf say_hello

# run a subshell
bash

# should be able to run the function now
say_hello
# hello
```

### Working with Arguments and Returns

Functions can accept arguments similar to scripts.

Example, could invoke a function like:

```bash
$ create_user tux foo
# inside the function:
#   tux would be $1
#   foo would be $2
#   all args would be $*
```

**Return Values**

Use the `return` command similar to `exit`. Value acts as an exit code to the function and the return command will quite the function without further code execution. Similar to how `exit` is used in a script.

Any non-zero return is considered an error:

```bash
# anywhere in function - error
return 1

# anywhere in function - success
return 0
```

**Example: Create User**

```bash
function create_user () {
  # redirect to dev/null so the caller of this function won't see the output
  if ( getent passwod $1 > /dev/null ); then
    echo "$1 already exists";
    return 1;
  else
    echo "Creating user $1";
    sudo useradd $1;
    return 0;
  fi
}
```

**NOTE about getent**

The getent command is used to retrieve information from system databases such as the user database (`/etc/passwd`), group database (`/etc/group`), and service database (`/etc/services`), etc. It is a command-line utility that allows you to query the Name Service Switch (NSS) libraries to retrieve information from a variety of sources, including local files, NIS, LDAP, and DNS.

The syntax of the getent command is as follows:

```bash
getent database [key...]
getent passwd username
```

### Best Practices

Functions should be standalone and not dependent on other elements such as variables from the master script. Otherwise it limits how much the function can be used in other scripts.

**Bad**

This function relies on `$age` variable being set in the shell:

```bash
function print_age () {
  echo $age
}
```

Also bad - if the shell happened to have an `$age` variable, calling this function would overwrite it which is unexpected:

```bash
function print_age () {
  age=$1
  echo $age
}

echo $age
# empty
print_age 5
# 5
echo $age
# 5 <- side effect, function leaked `age` var into shell
```

**Good**

This function takes the value as an argument, setting the variable in the function still allows the variable to be named, but doesn't rely on calling shell. Local var prevents `$age` leaking to the shell:

```bash
function print_age () {
  # local keyword ensures age var is only available in this function
  # and does not leak out to the shell
  # also good practice to name the variable `age` rather than just referencing $1, $2, etc.
  local age=$1
  echo $age
}
```

### Summary

**List functions**
* detailed: `declare -f`
* summary: `declare -F`

**Export function**
* `declare -fx function_name`

**Unset function**
* `unset -f function_name`

Exit function using `return`

Keyword `local` to keep variable declarations local to function.

Design functions to be standalone.

## Understanding Shell Iteration Using Loops

### Introducing While and Until Loops

**Loops**

Looping structures are for iteration through a list of group of items. Eg: create 12 users that need similar properties.

While/Until: Loop while a `condition` is true or `until` the condition becomes true.

**While Example**

```bash
# declare an integer variable `x` with an initial value of 10
declare -i x=10

# Loop structure starts with keyword `do` and ends with keyword `done`
# print out the value of x to the console as long as x is greater than 0
# Note use of advanced arithmetic ops using double round parens, spacing is important!
while (( x > 0 )) ; do
  echo $x
  # decrement x
  x=x-1
done
```

Output:
```
10
9
8
7
6
5
4
3
2
1
```

**Until Example**

```bash
#!/bin/zsh

declare -i x=10

until (( x == 0 )) ; do
  echo $x
  x=x-1
done
```

Output:
```
10
9
8
7
6
5
4
3
2
1
```

### Understanding For Loops

Iterate over a list, list may be manually created or generated from a command. There are multiple "style" of the for loop.

**C-style Loop**

Takes 3 expressions, separated by semi-colon:
1. Initialize the variable
2. Test the variable
3. Increment (`++`) or decrement (`--`) the variable

Example of increment on multiple lines:

```bash
for ((i=0 ; i<5 ; i++)); do
  echo $i
done
```

Can also write on single line, this example decrements:

```bash
for ((i=5 ; i>0 ; i--)); do echo $i; done
```

**Iterating an Array**

Use C-style for loop to iterate over each item in an array. Can test elements of array for a condition.

Note that on Mac, arrays are 1-based so have to start for loop index at 1 rather than 0, and test for less than or equal to rather than strictly less than.

```bash
#!/bin/zsh

# declare an indexed array
declare -a users=("bob" "joe" "sue")

# count elements in array
echo ${#users[*]}

for ((i=1; i<=${#users[*]}; i++)); do
  echo ${users[$i]}
  # sudo useradd ${users[$i]}
done
```

**Classic FOR Loop**

List referred to with the `in` keyword can be static or dynamic:

```bash
for f in $(ls); do stat -f "%z %N" $f ; done
```

Left at 3:40
