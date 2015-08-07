"format es6"
/**
 * Contact information (cover)
 */

import branding from 'branding.js';

Polymer.Base.importHref('components/contact.html', function() {

Polymer({
	is: 'sd-contact',
	ready() {
		if (branding === 'screamingbox') {
			let email = Polymer.dom(this).querySelector('.contact-info .email');
			
			if (email) {
				email.textContent = 'andras.sevcsik@screamingbox.com';
				email.href = `mailto:${email.textContent}`;
			}
		}
	}
});

});
