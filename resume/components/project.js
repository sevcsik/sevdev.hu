"format es6";
/**
 * Project component
 * @class sd-project
 */

Polymer.Base.importHref('components/project.html', function() {

Polymer({
	is: 'sd-project',
	ready() {
		let elements = Polymer.dom(this).querySelectorAll('[buzzwords] > *');
		this._buzzwords = [...elements].map((element) => element.textContent);

		if (Polymer.dom(this).querySelector('img')) {
			Polymer.dom(this.$.header).classList.add('has-image');
		}
	}
});

});
