-----------------------------------------------
title: "Writing CSS that scales: Encapsulation"
-----------------------------------------------

Usually we don't take code organisation and architectural discipline seriously when writing stylesheets, because it's
"just CSS". But over time, when your product grows, things get ugly. Changes in one component break the other,
implementing a facelift on a shared component makes the whole product fall apart.

**CSS is code**, and just like any other code, it needs to have a design, be refactored time to time and adhere to
set of common principles in order to scale. As any other language, it needs to be learned and it is hard.
Don't be like [this guy][griffin-gif].

<!-- TEASER -->

If you're using a somewhat modern front-end framework (like Angular, React, or more recently [Web Components]), you're
building your UI out of components. Likely these components are identified by a custom HTML element name, and a
fixed, well-defined API for changing it's inner content (attributes/properties or DOM insertion points).

Now, you wouldn't override the inner variables outside the component, would you? That would break the encapsulation:
you no longer use the API to customise the behaviour, but your code will rely in the inner workings of the component,
making your code break when it's refactored.

The same applies to CSS: the inner DOM of a component is private and is a subject to change. Unfortunately CSS doesn't
know these boundaries because they are defined by your UI framework (unless you use [Shadow DOM]).

So it's up to your diligence to not cross this boundary. Let's say you have a `my-message-bubble` element which
displays an important message in a coloured box. Like this:

```html
<my-message-bubble id="mybubble" type="error">Oh no!</my-message-bubble>
```
Which gets rendered into:
```html
<my-message-bubble id="mybubble" type="error">
    <div class="msg-background error">
        <span class="msg-text">Oh no!</span>
    </div>
</my-message-bubble>
```

This element can accept "error" and "info" messages which paints a red or blue box with a message in it. But in your
story, you need a yellow background, because it's a warning!

DON'T write CSS that relies on DOM which is not owned by you
------------------------------------------------------------

It's an easy thing to do from CSS:

```css
#mybubble .msg-background {
  background: yellow;
}
```

With this solution, you suddenly rely on

 - there is an `.msg-background` element rendered by the component
 - the background colour is set by having a `background` rule on that element

It's easy to see that that your code will break if somebody wants to change the inner DOM of `my-component`, or even if
they just decide to use `background-color` instead of `background`. It's not just about refactoring: maybe the author
will add an icon, or a border. Then you will have a yellow box with red border and an error icon.

When your product gets big, there will be hundreds of messages like this. Making the changes above will take
a week instead of an hour, because you'll have to scan every use case of your component if it still works as expected.

DO extend components with the needed behaviour
----------------------------------------------

Instead of overriding the CSS from the outside, extend the component so it will support a `warning` value in the `type`
attribute, and add the extra styling to the component's stylesheet.

If you work in a large organisation, this will take more time. Likely the component you modify is owned by another team.
It looks like an overhead, but actually, it serves you good. It makes you **think twice** before changing an existing
UI component.

DO think before changing an existing UI component
-------------------------------------------------

Are you sure you're using the correct element? Maybe **there's a reason** for `my-message-bubble` supports only `error`
and `info`. Maybe there's another element for displaying warnings. Maybe there are no warnings in your project at all,
you're just the first to need it. In that case, all the others should need to display a warning, will be able
because of you, and all warnings will be displayed the same way in the future.

Doing this not just helps with code quality and refactoring, but it also helps with maintaining a
consistent user experience across the product. When a lot of people work on the same product, a some of them will think
differently, and come up with different UX patterns for the same problem.

This can quickly lead to a cluttered, inconsistent user experience which will be a huge job to untangle afterwards.
Honour encapsulation, and the UX people will love you.




[griffin-gif]: https://giphy.com/gifs/frustrated-annoyed-programming-yYSSBtDgbbRzq
[Web Components]: https://developer.mozilla.org/en-US/docs/Web/Web_Components
[Shadow DOM]: https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_shadow_DOM





