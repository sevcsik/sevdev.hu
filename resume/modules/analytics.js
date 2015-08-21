/* global t0, Keen */

/**
 * Analytics module for keen.io
 * @class analytics
 */

import '../bower_components/keen-js/dist/keen.js';

let P = 'analitycs: ';
let keen = new Keen(
	{ projectId: '54c77fc096773d7636acb3da'
	, writeKey: 'eae83ff59155c9334cf8b43a36cff34fab120670b52c09d9e58c802838e846302b3991df491a3f7c05d39aa0204dfcb6e32ebaa0ab8636a2d22541fd06aeb6de08381369aca839359d1908b11fbcecd8ae383a7b008303c51e340bed4a9ce6e3598efa7957f06faed2de4863c18d0dd9'
	});

let addTime = (obj) => {
	if (typeof obj !== 'object') obj = {};
	obj.time = Date.now() - t0;
	return obj;
};

let viewedFragments = [];

export default {
	ready() {
		keen.addEvent('ready', addTime());
	},

	fragmentView(fragmentId) {
		// send fragmentViews only once
		if (!viewedFragments.find(e => e === fragmentId)) {
			keen.addEvent('fragmentView', addTime({ fragment: fragmentId }));
			viewedFragments.push(fragmentId);
		}
	}
};

// send impression event
keen.addEvent('impression',
	{ url: document.location.toString()
	, fragment: document.location.hash
	, query: document.location.search
	, userAgent: navigator.userAgent
	, width: window.innerWidth
	, height: window.innerHeight
	}, (err) => err && console.error(`${P}impression: failed to add event`)
);
