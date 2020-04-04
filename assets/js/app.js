// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";
import {Socket} from "phoenix";
import {LiveSocket} from "phoenix_live_view";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import Hooks from "./hooks";

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}});
liveSocket.connect();

const mobileMenuToggle = document.getElementById("menu-toggle");
const menu  = document.getElementById("mobile-menu");

if (mobileMenuToggle) {
  mobileMenuToggle.addEventListener("click", (e) => {
    menu.classList.toggle("block");
    menu.classList.toggle("hidden");

    const links = menu.getElementsByTagName("a");

    for (let link of links) {
      link.addEventListener("click", (e) => {
        menu.classList.add("hidden");
        menu.classList.remove("block");
      });
    }
  });
}


function toggle() {
  console.log("toggle check!");
}
