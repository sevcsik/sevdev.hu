/**
 * Root element
 * @class sd-resume
 */

import 'bower_components/es6-shim/es6-shim.min.js';

import 'components/header.js';
import 'components/menu.js';
import 'components/contact.js';

Polymer.Base.importHref('components/resume.html', function() {

Polymer({
	is: 'sd-resume',

	ready() {
		this.classList.remove('plain');
		this.classList.add('rich');

		this.addEventListener('sd-menu-click', 
			() => this.$.drawer.togglePanel());;

		let previousPos = 0;

		// Add scroll visibility classes to the positions to every child
		let onScroll = () => {
			let viewTop = this.$.panel.$.mainContainer.scrollTop;
			let viewHeight = this.$.panel.offsetHeight;
			let viewBottom = viewTop + viewHeight;
			let children = Polymer.dom(this).querySelector('main').children;

			[...children].forEach((child) => {
				let childTop = child.offsetTop;
				let childHeight = child.offsetHeight;
				let childBottom = childTop + childHeight;
				let classes = child.className;
				let isQuartileVisible = (n) =>
					   childTop + n * childHeight / 4 >= viewTop
					&& childTop + n * childHeight / 4 < viewBottom;

				// clean up previous scroll classes
				classes = classes.replace(/ scroll-[a-z0-9-]+/g, '');


				if ((childTop >= viewTop && childTop < viewBottom)
				   || (childBottom >= viewTop && childBottom < viewBottom)) { 
					// child is visible
					classes += ' scroll-visible';
					
					// add class for every visible quartile
					[1, 2, 3].forEach((n) => {
						if (isQuartileVisible(n))
						   	classes += (' scroll-visible-q' + n);
						else
							classes += (' scroll-hidden-q' + n);
					});
				} else {
				   classes += ' scroll-hidden';
				}	   

				child.className = classes;
			});
		};

		onScroll(); // apply scroll classes as soon as everyting is set up
		this.$.panel.$.mainContainer.addEventListener('scroll', onScroll);
	}
});

});
