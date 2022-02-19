// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

import "../css/app.scss";

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix";
import {LiveSocket} from "phoenix_live_view";
import topbar from "topbar";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import Hooks from "./hooks";
import displayCookies from "./cookies";

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}});

// Show progress bar on live navigation and form submits
topbar.config({barColors: { 0: "#F56565" }, shadowColor: "rgba(0, 0, 0, .3)" });

let topBarScheduled = undefined;
window.addEventListener("phx:page-loading-start", () => {
  if(!topBarScheduled) {
    // only show topbar if page load takes longer than 120 ms
    topBarScheduled = setTimeout(() => topbar.show(), 120);
  };
});
window.addEventListener("phx:page-loading-stop", () => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  topbar.hide();
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

displayCookies();

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
