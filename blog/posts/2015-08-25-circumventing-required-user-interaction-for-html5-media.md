------------------------------------------------------------------
title: Circumventing required user interaction to play HTML5 media
------------------------------------------------------------------

Webkit (and Blink) includes [a limitation][1] on mobile, that calling
`HTMLMediaElement#play` has no effect unless it was initiated
by user interaction. That supposed to make autoplay impossible, thus
saving mobile users from unwanted data traffic in their plan by
background music and autoplaying videos. Fair enough.

If you are using something like [secure tokens][2] to protect your media URLs, 
you ask your backend for a fresh token to get the actual video URL to play. 
Since this operation is asynchronous, you can't call `play` soon
enough, having your call disarmed. To the end user, this means that
they have to tap your play button twice to start the video.

<!-- TEASER -->

This "feature" is surprisingly poorly documented. No implementation
details, just a few bug reports, all about breaking autoplay. After a few
hours of empirical testing, I found out that there can be maximum one
second between a `click` event and your `#play` call, otherwise you're just
trying to get blood out of a stone.

There's a loophole though: once you have "woken" up your `<video>` tag with
a legitimate `#play()`, every subsequent call will work afterwards. You don't
even have to have an URL loaded to do so.

So the workaround looks something like this:

``` html
<video id="video" controls></video>
<button onclick="playAsync()">play</button>
<script>
	var v = document.getElementById('video');
	function playAsync() {
		v.play();
		v.pause();

		setTimeout(function() {
			v.src = URL;
			v.play();
		}, 5000);
	}
</script>
```

Interestingly, if you remove the `v.pause()` call, it won't work. I suspect
that the browser would find out that there is no media to play in the next
[tick][3], rendering the playback state change invalid.

Tested on iOS7+ Safari and Chrome for Android.
 
[1]: https://code.google.com/p/chromium/issues/detail?id=178297
[2]: https://client.cdn77.com/support/knowledgebase/cdn-resource/how-can-i-enable-disable-secure-token
[3]: http://blog.carbonfive.com/2013/10/27/the-javascript-event-loop-explained/

