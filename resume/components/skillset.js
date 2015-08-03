/**
 * Display a single skillset
 */

import d3 from 'bower_components/d3/d3.min.js';

Polymer.Base.importHref('components/skillset.html', () => {

var levels =
	{ beginner: 1
	, experienced: 2
	, senior: 3
	};

Polymer({
	is: 'sd-skillset',

	created() {
		let data = this._parseDOM();
		let end = this.getAttribute('end');

		console.log(end, data);
	},

	_parseDOM() {
		let data = [];

		d3.selectAll(Polymer.dom(this).querySelectorAll('[skill]'))
			.each(function() {

			let el = d3.select(this);
			let name = el.select('[name]').text();
			let level = levels[el.select('[level]').text()];
			let featured = el.attr('featured') !== null;

			data.push({name, level, featured});
		});

		return data;
	}
});

});
