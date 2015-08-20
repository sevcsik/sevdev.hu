/**
 * Root element
 * @class sd-resume
 */

import analytics from 'analytics.js';

import 'components/header.js';
import 'components/menu.js';
import 'components/contact.js';
import 'components/skillset.js';
import 'components/project.js';
import 'components/timeline.js';

Polymer.Base.importHref('components/resume.html', function() {

Polymer({
	is: 'sd-resume',

	ready() {
		this.classList.remove('plain');
		this.classList.add('rich');

		this.addEventListener('sd-menu-click',
			() => this.$.drawer.togglePanel());

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
					[0, 1, 2, 3, 4].forEach((n) => {
						let postfix = n === 0 ? '-top'
									: n === 4 ? '-bottom'
									: `-q${n}`;

						if (isQuartileVisible(n)) {
							classes += (' scroll-visible' + postfix);
							if (child.id) {
								analytics.fragmentView(child.id);
							}
						} else {
							classes += (' scroll-hidden' + postfix);
						}
					});
				} else {
					classes += ' scroll-hidden';

					if (childTop < viewTop) {
						classes += ' scroll-hidden-above';
					} else {
						classes += ' scroll-hidden-below';
					}
				}

				child.className = classes;
			});
		};

		onScroll(); // apply scroll classes as soon as everyting is set up
		this.$.panel.$.mainContainer.addEventListener('scroll', onScroll);

		analytics.ready();
	}
});

});
