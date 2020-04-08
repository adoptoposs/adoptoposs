const subscribeEventHandler = (el) => {
  el.addEventListener("click", e => {
    const closed = el.parentElement.getAttribute("open") == null;

    if (closed) {
      const copyIcon = el.parentElement.querySelector("[data-copy-action");
      const successIcon = el.parentElement.querySelector("[data-copy-success");

      copyIcon.classList.remove("hidden");
      successIcon.classList.add("hidden");
    }
  });
}

const ResetOnClose = {
  mounted() {
    subscribeEventHandler(this.el);
  },
};

export default ResetOnClose;
