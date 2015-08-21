"format es6";

let matches = document.location.search.match(/branding=([a-z]+)/);
export default matches && matches[1];

