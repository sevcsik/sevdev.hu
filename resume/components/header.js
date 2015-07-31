/**
 * Root element
 * @class sd-resume
 */

Polymer.Base.importHref('components/header.html', function() {

Polymer({
	is: 'sd-header',
	listeners: {
		'menu.click': 'onMenuClick'
	},
	onMenuClick(e) {
		this.fire('sd-menu-click');
	}
});

});
