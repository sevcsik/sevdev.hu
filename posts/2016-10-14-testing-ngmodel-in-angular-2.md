---
title: Testing ngModule in Angular 2
---

Angular has always put an emphasis on automated testing. Angular 2 continues
this tradition - the question testing is ubiquitous, both the core design and
the documentation, which is great.

Unfortunately, Angular 2 is a much more delicate and complex environment
than Angular 1, so are the testing tools. This is a case study of testing a simple 
component with two-way binding, highlighting the pitfalls to avoid.

<!-- TEASER -->

*If you want to run the code examples, grab the [example repository][1] - it has
a commit for each section.*

Let's create a simple component to test. I cut the boilerplate, here's just the
essence:

```javascript
export class AppComponent {
  theValue = 'lowercase';
}

```

```html
<input [(ngModel)]="theValue">
<code>{{ theValue | uppercase }}</code>
```
Our requirement is pretty simple: What comes in the `<input>` should come out
in uppercase in the `<code>`.

# The naive approach

Let's try (and fail miserably):
```javascript
// put our test string to the input element
fixture.debugElement.query(By.css('input')).nativeElement.value = 'test';

// expect it to be the uppercase version
expect(fixture.debugElement
              .query(By.css('code'))
              .nativeElement
              .textContent
      ).toEqual('TEST');
```

Result: `Expected '' to equal 'TEST'` :(

Of course it fails! For a good reason: Angular doesn't (cannot) update the
bindings instantly. This is familiar from Angular 1 - we needed to call the
dreaded `$scope.apply()` to trigger the digest loop, or wait for it to happen
by itself.

# The change detector

The Angular2 equivalent of this is [`ChangeDetectorRef#detectChanges()`][2].
Int the test environment, it's exposed on `CompnentFixture`, and calling
it will detect the changes and update the binings. Nice.

```javascript
it( 'should put the uppercased version of the input field\'s input into'
  + 'the code element', () => {

// put our test string to the input element
fixture.debugElement.query(By.css('input')).nativeElement.value = 'test';
fixture.detectChanges();

// expect it to be the uppercase version
expect(fixture.debugElement
              .query(By.css('code'))
              .nativeElement
              .textContent
      ).toEqual('TEST');
});
```

Result: `Expected 'LOWERCASE' to equal 'TEST'.` :(

A bit better, right? Now at least we have the initial value going through.
The reason is that TestBed doesn't run the change detector at all,
unless asked to - so by default, not even the initial bindings are executed.
(This behaviour can be changed with [`Fixture#autoDetectChanges`][3].)

# Triggering NgModel

What we want to see, is the new value we put in the input field, not the
initial one. The issue is that even though	we updated the value property,
that doesn't trigger NgModel's binding by itself. It listens to the `input` event,
which is dispatched only on actual user input.

All we need to do is to dispatch an [`InputEvent`][4] (did you know that's a
thing?) on element and we're good to go. Right?

```javascript
it( 'should put the uppercased version of the input field\'s input into'
  + 'the code element', () => {

  // put our test string to the input element
  let element = fixture.debugElement.query(By.css('input')).nativeElement
  element.value = 'test';
  element.dispatchEvent(new Event('input'));
  fixture.detectChanges();

  // expect it to be the uppercase version
  expect(fixture.debugElement
                .query(By.css('code'))
                .nativeElement
                .textContent
        ).toEqual('TEST');
});
```

Result: `Expected 'LOWERCASE' to equal 'TEST'.` :(

# NgModel is asynchronous

Now this is where it gets funky. After a bit searching, I found a [commit to
the changelog][5] which explains it: NgModel updates became asynchronous, so
fixture.detectChanges() won't be reflected instantly. We have to use the
`Fixture#whenStable` method, which gives us a promise to the stabilised state.

```javascript
it( 'should put the uppercased version of the input field\'s input into'
  + 'the code element', () => {
  fixture.detectChanges();

  // put our test string to the input element
  let element = fixture.debugElement.query(By.css('input')).nativeElement;
  element.value = 'test';
  element.dispatchEvent(new Event('input'));

  fixture.whenStable().then(() => {
    // expect it to be the uppercase version
    expect(fixture.debugElement
                .query(By.css('code'))
                .nativeElement
                .textContent
          ).toEqual('TEST');
  });
});

```

Result (wait for it): *It works!*

Note that I moved the `fixture.detectChanges()` call to the top,
because alhtough we don't need it anymore *after* we make changes, we still need
an initial call to build the initial state of our component.

Now we are using promises. You don't need to have a wild imagination to see
this would look like a mess on more complicated test scenarios, if we had to chain
every exception after a promise.

# Making it readable again

Thankfully, Angular 2 provides a utility, called [`fakeAsync`][6], which magically
allows us to turn our code sync again, with the help of the `tick` function.
We just have to put the `it` callback into a `fakeAsync` wrapper, and we can
"suspend" our flow until the async operations are ready.

Behold:
```javascript
it( 'should put the uppercased version of the input field\'s input into'
  + 'the code element', fakeAsync(() => {
  fixture.detectChanges();

  // put our test string to the input element
  let element = fixture.debugElement.query(By.css('input')).nativeElement;
  element.value = 'test';
  element.dispatchEvent(new Event('input'));

  tick();
  fixture.detectChanges();

  // expect it to be the uppercase version
  expect(fixture.debugElement
              .query(By.css('code'))
              .nativeElement
              .textContent
        ).toEqual('TEST');
}));
```

It looks fine now, doesn't it? 

[1]: https://bitbucket.org/sevcsik/ng2-ngmodel-testing-demo
[2]: https://angular.io/docs/ts/latest/api/core/index/ChangeDetectorRef-class.html
[3]: https://angular.io/docs/ts/latest/api/core/testing/index/ComponentFixture-class.html#!#autoDetectChanges-anchor
[4]: https://developer.mozilla.org/en-US/docs/Web/Events/input
[5]: https://github.com/angular/angular/commit/f444c11d218d26ac817d5f3b12e19c6b4b8d2390
[6]: https://angular.io/docs/ts/latest/guide/testing.html#!#the-_fakeasync_-function
