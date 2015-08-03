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

	ready() {
		this.data = this._parseDOM();
		this.end = this.getAttribute('end');

		let featured = this.data.filter((d) => d.featured);

		console.log(featured);

		d3.select(Polymer.dom(this.root).querySelector('#columns'))
			.selectAll('rect')
			.data(featured)
			.enter()
			.append('rect')
			.filter((d) => d.featured)
			.classed({ column: true, 'sd-skillset': true }) // Polymer should add this
			.attr('x', (d, i) => i * 100 / featured.length)
			.attr('y', (d, i) => 25 * (4 - d.level))
			.attr('width', 100 / featured.length)
			.attr('height', (d, i) => (d.level + 1) * 25)
		;

		d3.select(Polymer.dom(this.root).querySelector('#labels'))
			.selectAll('text')
			.data(featured)
			.enter()
			.append('text')
			.text((d) => d.name)
			.classed({ label: true, 'sd-skillset': true })
			.attr('text-anchor', 'end')
			.attr('transform', 'rotate(-90)')
			.attr('x', 0)
			.attr('y', (d, i) => 14 + (i * 100 / featured.length))
		;
			
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
