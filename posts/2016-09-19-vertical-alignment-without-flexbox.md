=============================================
title: CSS vertical alignment without flexbox 
=============================================

If you're unlucky enough to have to support [non-flexbox-capable browsers][1],
I'm pretty sure you had nightmares about vertical alignment. It's the most
ridiculously complicated thing in CSS. There are urban legends about people,
who once aligned a box vertically in the middle of the screen, but they have
never been seen again. 

<!--  TEASER -->

Usually, the solution is the following: use absolute positioning, `top: 50%`,
and use negative margins to set the size of the element. If you can `calc()`, 
even better. 

However, this only works if you know the height of the element beforehand. 
This is not always the case: you might want to have a dialog which grows with
the content. And it's counter-intuitive as well: negative margins just don't make sense. 

We do have something though that looks like exactly what we need. It's called
`vertical-align: middle`, the first disappointment in every web developers life. 
It seems to be the obvious solution - but it just doesn't work. 

The reason is that `vertical-align` is for text formatting. It doesn't set the alignment 
of the children of the element, like `text-align`, but it sets the alignment 
of the children themselves, relative to each other. This is a very common issue
in HTML: It is designed around flowing text, not UI, so it feels unnatural 
to do things with it which should be obvious in a UI development framework. 

That doesn't mean we cannot use `vertical-align`, we just need to be a bit creative. 
Let's say we have a `.container` element, and a `.box`. As we already know, it should be applied 
to `.box`, not `.container`, but it still doesn't seem to be doing anything. The reason is that
it is the only child, there's nobody to align to. We need to add another one, as a reference. 
We can use a `::before`. This will be a ruler which we can measure our `.box`against. 

We use an `inline-block` display for both of our elements, so
we can align them nicely. Our 'ruler' should have a 100% height, so it's like we were aligning 
to the container's. Width should be 0, to hide it. And voilà, our box is vertically aligned! 

Check out the working example (borders added for demonstration):

<iframe width="100%" height="300" src="//jsfiddle.net/hx00epqu/18/embedded/html,css,result/?accentColor=%237f262&menuColor=%23E5E5E&bodyColor=%23fff&fontColor=%23333" allowfullscreen="allowfullscreen" frameborder="0"></iframe>

[1]: http://caniuse.com/#feat=flexbox
