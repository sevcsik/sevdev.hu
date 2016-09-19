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
`vertical-align: middle`. Probably the first disappointment in every web developers life. 

[1]: http://caniuse.com/#feat=flexbox
