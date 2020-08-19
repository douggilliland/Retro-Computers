(function(){/* 
 
 Copyright The Closure Library Authors. 
 SPDX-License-Identifier: Apache-2.0 
*/ 
var e=document;function h(){for(var a=e.head,b=a.querySelectorAll("link[data-reload-stylesheet][as=style][rel=preload]"),f=0;f<b.length;f++){var l=b[f],c="link",g=document;c=String(c);"application/xhtml+xml"===g.contentType&&(c=c.toLowerCase());c=g.createElement(c);c.setAttribute("rel","stylesheet");c.setAttribute("href",l.getAttribute("href"));a.appendChild(c)}if(0<b.length){var d=void 0===d?.01:d;if(!(Math.random()>d)){a=document.currentScript;a=(a=void 0===a?null:a)&&26==a.getAttribute("data-jc")?a:document.querySelector('[data-jc="26"]'); 
d="https://pagead2.googleadservices.com/pagead/gen_204?id=jca&jc=26&version="+(a&&a.getAttribute("data-jc-version")||"unknown")+"&sample="+d;a=window;if(b=a.navigator)b=a.navigator.userAgent,b=/Chrome/.test(b)&&!/Edge/.test(b)?!0:!1;b&&a.navigator.sendBeacon?a.navigator.sendBeacon(d):(a.google_image_requests||(a.google_image_requests=[]),b=a.document.createElement("img"),b.src=d,a.google_image_requests.push(b))}}};function k(){new h}"complete"===e.readyState||"interactive"===e.readyState?k():e.addEventListener("DOMContentLoaded",k);}).call(this);
