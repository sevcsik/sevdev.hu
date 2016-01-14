import { Component } from 'angular2/core';

let staticElement: HTMLElement = 
	(<NodeListOf<HTMLElement>>document.getElementsByTagName('sd-main'))[0];
let template: string = staticElement.innerHTML;

@Component({ selector: 'sd-main'
          , template
          })

export class MainComponent {}
