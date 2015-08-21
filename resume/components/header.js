/* global Polymer */
/**
 * Root element
 * @class sd-resume
 */

Polymer({
	is: 'sd-header',
	listeners: { 'menu.click': 'onMenuClick'
	           , 'print.click': 'onPrintClick'
	           },
	onMenuClick() {
		this.fire('sd-menu-click');
	},
	onPrintClick() {
		window.print();
	}
});
