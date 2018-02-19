title: First-class Functions in JavaScript
------------------------------------------

The notion of first-class functions can be somewhat puzzling for those who are just starting with JavaScript, especially if they come from a Java background (as Java has only introduced them in version 8).

Understanding first-class funtions is crucial in the JavaScript world as they are unavioidable when dealing with event handlers, non-blocking (asynchronous) I/O and they are the fundamental to functional programming.

<!-- TEASER -->

If a language has "[first-class functions][1]" then the language doesn't make a difference between functions and data. This usually means that a function declaration is an *expression* instead of a *statement*. Any expression can yield any kind of value, like a boolean, or Object, or in our case a function - it makes no difference to the language.

# Declaring functions

In JavaScript it's a bit confusing that a function declaration can also be a *statement*, similar to the `var` keyword in some special cases. See the following example:

```javascript
f();
function f() { console.log('hello, world!') }
```

In this case, the `function` keyword acts as a *declaration statement*, similar to `var`, `let` and others. Even the invocation of our function happens before the declaration, it can still be used thanks to [declaration hoisting][2].

In the following example, we assign the function to a variable:

```javascript
f(); // exception: f is not defined.
g(); // exception: g is not a function.
var g = function f() { console.log('hello, world!') }
```

What happens here? First of all, we notice that we don't have a function `f` defined anymore. That's because as soon as we *use* the value of it, the `function` keyword will act as an *expression* instead of a *declaration statement*. Hence the name `f` is not declared in our scope, but it's returned as the result of the expression, which is assigned to our variable `g`.

How come `g()` doesn't work? And why does it throw a different exception? To understand that, we have to check *declaration hoisting* again. The `var g` statement is *hoisted*, so our code will effectively turn into this:

```javascript
var g = undefined
f()
g()
g = function f() { console.log('hello, world!') }
```

Remember, assignment is an *expression* while variable declaration is a *statement*, and only the latter is hoisted. That explains the different exception: when we say `g()`, in fact we say `undefined()` which is invalid as `undefined` is not a function.

We could drop the name `f` here because the only reference we'll have for the function is `g`. However, `f` is still the *name* of the function (`g.name` will yield `"f"`), and it will appear in the debugger as `f`. Modern JavaScript engines [can infer][3] the name of functions declared in function expressions, so if we dropped the `f` and went with `function() {}`, they would set the function's name to `"g"`. That means it's no longer necessary to awkwardly name anonymous functions just to ease the debugging (unless you plan to debug in IE of course :)).

Since ES2015, there's an alternative way to declare anonymous functions (a.k.a. *lambdas*) called [*arrow functions*][4]:

```javascript
    const f = a => a + 1
    const g = (a, b) => {
        console.log(b);
        return a;
    }
```

Note that we used the `const` keyword to declare variables that holds our function. Unless you want to change the *implementation* behind `f` and `g` later, you should always use `const`, as the function itself won't change. Making this clear will help the JavaScript runtime to optimise your code better (and will aid your fellow developers understanding your work).

Using the `() => {}` syntax, fat arrow functions work just like regular functions (except their context, more on that later). If you have exactly one parameter, the parentheses are optional. You can define one-liners by omittiing the curly braces: in this case the `return` statement is *implied* (`f = a => { return a + 1 }` would have the same meaning as the above).

# Higher-order functions

Any expression can yield a function, and any expresion can be used as an argument or returned from a function, which implies that we can create functions which take other functions as parameters and return functions. Such functions are called *higher-order functions*.

Perhaps the most common higher order function is the `map` function. In the following example, we create a function which returns an arbitrary field of an object (usually called `pluck`) and map it to an array of objects.

```javascript
const pluck = field => item => item[field]
const objects = [ { a: 5, b: 1 }, { a: 'asd', x: 1 } ]
objects.map(pluck('a')) // yields [ 5, 'asd' ]
```

Our definition of `pluck` might look strange, so let's convert it to the usual `function` syntax:

```javascript
const pluck = function(field) {
    return function(item) {
        return item[field]   
    }
}
```

Our `pluck` function takes a field name and returns a function which takes the actual object and extracts that field. Since it returns a function, it is a *higher-order* function. We could use our function to extract a field from a single object like this: `pluck({ a: 5, b: 1 })('a')`. This is what we call a *[curried function][5]*: if we call it with just one parameter, it yields a function which takes the second parameter only, if it's called with both parameters, it yields the actual result. We can also say that if we call it with only one argument, we [*partialy apply*][6] the first argument to our function.

Unfortunately JavaScript doesn't support currying natively, so we have to use this weird `()()` syntax when calling curried functions. Much cooler languages such as Haskell or ML support curried functions (in fact they support *only* curried functions) natively, so no special syntax is needed.

To understand how `pluck` works, we need to understand [lexical scoping][7].

[1]: https://en.wikipedia.org/wiki/First-class_function
[2]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/function#Function_declaration_hoisting
[3]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/name#Inferred_function_names
[4]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions
[5]: https://en.wikipedia.org/wiki/Currying
[6]: https://en.wikipedia.org/wiki/Partial_application
[7]: https://en.wikipedia.org/wiki/Scope_(computer_science)#Lexical_scoping