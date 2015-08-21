/* global Polymer */
/**
 * Timeline component
 * @class sd-timeline
 */

Polymer({
	is: 'sd-timeline',
	ready() {
		this._items = Polymer.dom(this).querySelectorAll('[timeline] [item]')
			.map((el) => (
				{ year: el.querySelector('[year]').textContent
				, title: el.querySelector('[title]').textContent
				, subtitle: el.querySelector('[subtitle]').textContent
				}
			));
	},
	_getItemStyle(index) {
		// we have a gap after the first element
		let position = 0;

		if (index) {
			position = (index + 1) * 12;
		}

		return `top: ${position}%`;
	}
});
