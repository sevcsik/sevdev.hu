---------------------------------------------------------
title: "Writing CSS that scales: Thinking inside the box"
---------------------------------------------------------

*This post is the continuation of my [previous post about encapsulation].*

More often than not, we don't come up with a design on our own, but we get it from another team. Sometimes it's just a
screen plan, other times just a mockup. If you use some fancy collaboration app, like InVision or Zeplin, you can even
extract exact geometries and even CSS snippets extracted from these screen plans.

It's tempting to go with the convenient way and just put every pixel you see on the plan to code. After all, that will
definitely be according to the specs. Unfortunately the web doesn't work that way -- it cannot be modeled with one or
more static images.

Thinking about what you're implementing not just helps you with preparing your software for a range of browser window
sizes, it will also help you creating a stylesheet that's not horrible to modify later on.

<!-- TEASER -->

Let's take a look at this finely crafted screen plan:

<img src="/images/scalable-css-2-fig1.jpg" alt="Example of a design specification" height="300">

We see 8 different geometries here:

 - The screen's width is 470px
 - One list element is 60px tall
 - The icon in a list element is 40px tall
 - The spacing between two list items is 20px
 - The OK button's text is 30px tall
 - The OK button itself 120px wide and 50px tall
 - There is a 350px spacing right to the OK button

Maybe you don't have any geometries displayed in the mockup, but you can measure it on your own: in that case you can
get a lot of other numbers depending what you measure. The question is: which are the important ones you should code
in your CSS?

Page dimensions
===============

Let's start from the top. Most websites today chose the easy approach in terms of responsive design: the width of the
page is fixed on two or three breakpoints depending of the viewport size. This way, you don't have to worry about
an infinite number of screen sizes, but UX can deliver 2 or 3 screen plans for the different breakpoints. This scenario
is usually paired with vertical scrolling.

Some sites (usually web apps which try to emulate a desktop app UX) use a fluid layout, fix both width and
height to the viewport size, and manage the scrolling inside components only.

In both scenarios, you either choose to just fill the available area (whether it's a dialog window or a
full-screen page), so you don't have to define any width (as block elements fill horizontally the available space by
default).

If you happen to be the first person who needs a screen of this size, you might define a 470px wide container - but
you'll probably need to do it generally, so other, similar screens can reuse it. If you do, don't forget to check
that this value works well for all form factors.

Sizing container elements
=========================

There are two other elements on our mockup, which have inner content: the list item and the OK button.





[previous post about encapsulation]: https://sevdev.hu/posts/2019-02-03-writing-css-that-scales-encapsulation.html
