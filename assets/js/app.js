// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

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
import displayCookies from "./cookies";

displayCookies();

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}});
liveSocket.connect();

for (let el of document.getElementsByClassName("close-on-link-clicked")) {
  const links = el.getElementsByTagName("a");

  for (let link of links) {
    link.addEventListener("click", e => {
      setTimeout(() => el.removeAttribute("open"), 160);
    });
  }
}

window.addEventListener("phx:page-loading-stop", (info) => {
  if (!window.location.hash) {
    return;
  }

  const el = document.querySelector(window.location.hash);

  if (el) {
    el.scrollIntoView();
    el.classList.add("focused-anchor");
  }
});
