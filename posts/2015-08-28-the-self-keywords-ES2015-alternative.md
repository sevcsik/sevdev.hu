--------------------------------------------
title: The self keyword's ES2015 alternative
--------------------------------------------

It's quite a common use case that you need more types of constructors
for your class, like copy constructors, or creating an instance from
a plain object. With static methods, [you can easily do this][1].

However, if you extend your class with these alternative "constructors",
you probably don't want to redefine each in your child class just to
use it's own constructor, not the parent's.

<!-- TEASER -->

In this case, you need a keyword like PHP's `self`, which refers
to the class (or the constructor in ES5) of the instance.

Unfortunately ES2015 doesn't have a keyword like this. However, due to
the nature of Javascript, you can use the `this` keyword to access it.
As the `this` keyword is not bound in static methods (thank you
[BabelJS@slack][2] for confirming it), as long as call it as a method
of the child class, it will refer to it.

Here's an example of having a class which can be instantiated with a
regular constructor or from a plain object:

```javascript
class A {
	constructor(a1, a2) {
		this.a1 = a1;
		this.a2 = a1;
	}

	static fromVO(obj) {
		// for unknown reasons, we have to define the constructor
		// explicitly, otherwise it doesn't show up in the debugger			
		Object.defineProperty( Object.assign(Object.create(this.prototype), obj)
		                     , 'constructor'
		                     , { value: this }
		                     });
	}
}

class B extends A {
	constructor(a1, a2, b1) {
		super(a1, a2);
		this.b1 = b1;
	}
}

B.fromVO({ a1: 5
         , a2: 6
         , b1: 7
         }) instanceof B; // === true

```

Of course, if you just want to call the constructor, a `new this()` will do
the trick in your static method.

*An interesting bit is that even `B.prototype.constructor.name` is `"B"`,
the Chrome debugger still prints it as `Object { ... }`. After setting the
constructor on the instance explicitly, the correct `B { ... }` form shows up.
Apperently you don't need to do this if you're the using the `new` keyword.*

[1]: http://odetocode.com/blogs/scott/archive/2015/02/02/static-members-in-es6.aspx
[2]: https://babeljs.slack.com
