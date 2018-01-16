-------------------------------------------------
title: Marrying HTML imports and ES2015 Modules
-------------------------------------------------

Web is evolving, which is a good thing. Unsurprisingly, it's evolving in it's
good ol' webby way paved with polyfills, transpilers and conflicting standards.

Having [modules][1] in Javascript was certainly a long awaited feature, which
makes it a much better fit for developing large applications. 
The same goes for [Web components][2] in HTML. Finally we can build custom
elements without relying on huge frameworks and expensively 
[monitoring the DOM][3] or layering a [less expensive DOM][4] on top of it.

Of course, HTML imports can be used to load Javascript, and Javascript
can import HTML. You can be sure that there will be tools using every possible 
permutation. And you'll brain hurt making them work together.

<!-- TEASER -->

# The Polymer Way

If you look at the [Polymer catalog][5], you'll see that they envision a world
where *everything* is done by web components. Things like [this][6]:

``` html
<iron-ajax
    auto
    url="http://gdata.youtube.com/feeds/api/videos/"
    params='{"alt":"json", "q":"chrome"}'
    handle-as="json"
    on-response="handleResponse"
    debounce-duration="300"></iron-ajax>
```

Call me old fashioned, but I still think that HTML, as a markup languge
should be used solely for presentation, not for defining the application logic.
And `handleResponse` would still be implemented in Javascript, so what's
the point?

This way of thinking ensues that the unit of encapsulation is a component.
Each component consists of a `<dom-module>` definition, and/or a
`Polymer` call. There is no dependency injection, and your dependency graph
will be defined how HTML imports are nested in different components. And that
gives us the -- rather odd -- phenomenon that you write your [script-only
components][7] in HTML as well.

Not to mention that with `import`, Babel works out of the box, but if you
include your ES2015 code with regular `<script>` tags, it's tricky to get
it working (I didn't manage at least).

# A phatetic first try

I for one still think that Polymer is the best web component library out there,
and if you're into [material design][8] like me, using their `paper-*` 
components will save you tons of work. They also have a pretty solid way
of "emulating" shadow DOM without sacrificing speed, called the [shady DOM][9].
So I'm here to stay.

First I tried the obvious way: import HTML templates from my ES2015 modules,
like this:

``` javascript
Polymer.Base.importHref('template.html', function() {
	Polymer({ /* ... */ })
});
```

This approach works: you can use the `import` statement to require your
components, just like your other modules. Turns out to be terribly bad
for performance though, as:

- The initialization of the JS part is delayed by loading the template.
  If you have multiple levels of dependencies, this pretty much flattens
  your initialization.
- It breaks [vulcanize][10] which is essential to deploy your code
  into production (at least until HTTP/2 gets adopted).

# Best of Both Worlds

I ended up with the following: I use HTML imports to require the HTML
definitions for my custom elements, and using ES2015 modules to require
the Javascript parts. Unfortunately, this requires me to have an obligatory
JS and a HTML part for every element, but usually I end up needing both
anyway, so I can live with it.

This method works nicely with Vulcanize as well: it crunches through every
HTML import, while your JS bundler takes care all of your scripts.

There are a few things to look after though:

- You have to include `polymer.html` and `webcomponents.js` explicitly first,
  *then* you can load your JS entry point. Otherwise, every JS component 
  declaration will fail because `Polymer` is not yet defined.
- You have to include your initial HTML import(s) before the JS entry point
  as well. Turns out the `Polymer` call can happen *after* the `<dom-module>`
  declaration has been processed by Polymer, but not the other way around
  (if you see `this` pointing to `window` inside your element's lifecycle
  callback, that's the reason).
- If you don't use Vulcanize, be aware that native HTML imports are sync, but
  the polyfilled one (webcomponents.js) *is async*. That means you have to handle
  both cases. 

In the end it looks something like this (with [SystemJS][11] for dynamic loading):


``` html
<script src="bower_components/webcomponentsjs/webcomponents.min.js"></script>
<link id="polymer-import" rel="import" href="bower_components/polymer/polymer.html">
<script src="//cdnjs.cloudflare.com/ajax/libs/systemjs/0.18.4/system.js"></script>
<script>
	System.config({
		map: {
			babel: '//cdnjs.cloudflare.com/ajax/libs/babel-core/5.6.15/browser.min.js'
		},
		transpiler: 'babel'
	});
	var link = document.querySelector('#polymer-import');
	// wait for Polymer import
	if (link && link.import) {
		console.log('Delaying initial import until polymer is ready');
		document.querySelector('#polymer-import').addEventListener('load', 
			function() {
			System.import('components/resume.js');
		});
	} else {
		System.import('components/resume.js');
	}
</script>
```

And with a pre-compiled JS bundle (using [Webpack][12]):

``` html
<script src="https://cdnjs.cloudflare.com/ajax/libs/webcomponentsjs/0.7.12/webcomponents.min.js"></script>
<link id="polymer-import" rel="import" href="bower_components/polymer/polymer.html">
<link rel="import" href="components/my-main-component.html">
<script>
	(function() {
		var BUNDLE_PATH = "dist/scripts.js";
		var script = document.createElement('SCRIPT');
		script.src = BUNDLE_PATH;
		var link = document.querySelector('#polymer-import');
		// wait for Polymer import if necessary
		if (link && link.import) {
			document.querySelector('#polymer-import').addEventListener('load', 
				function() {
					document.head.appendChild(script);
				}	
			);
		} else {
			document.head.appendChild(script);
		}
	})();
</script>
```

This plays nice with both `<link>` tags inlined by Vulcanize (that's why I'm
checking for the existence of `link`). Although it's a bit painful, it does the job.

I'm open to suggestions!

[1]: http://www.2ality.com/2014/09/es6-modules-final.html
[2]: https://developer.mozilla.org/en-US/docs/Web/Web_Components
[3]: https://angularjs.org/
[4]: http://facebook.github.io/react/
[5]: https://elements.polymer-project.org/
[6]: https://elements.polymer-project.org/elements/iron-ajax
[7]: https://github.com/PolymerElements/iron-ajax/blob/master/iron-ajax.html
[8]: https://www.google.com/design/spec/material-design/introduction.html
[9]: https://www.polymer-project.org/1.0/articles/shadydom.html
[10]: https://github.com/polymer/vulcanize
[11]: https://github.com/systemjs/systemjs
[12]: http://webpack.github.io/
