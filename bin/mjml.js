// Take an mjml string and prints the compiled HTML
//
// **Example:
//   `mjml "<mj-html></mj-html>"`
//
var {html: html} = require('../assets/node_modules/mjml')(process.argv[2]);
console.log(html);
