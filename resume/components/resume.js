/**
 * Root element
 * @class sd-resume
 */

import 'components/header.js';
import 'components/menu.js';
import 'components/contact.js';

Polymer.Base.importHref('components/resume.html', function() {

Polymer({
	is: 'sd-resume',

	created() {
		this.classList.remove('plain');
		this.classList.add('rich');

		this.addEventListener('sd-menu-click', 
			() => this.$.drawer.togglePanel());;
	}
});

});