const subscribeEventHandler = (el) => {
  el.addEventListener("click", e => {
    el.parentElement.classList.toggle("toggled");

    const copyIcon = el.parentElement.querySelector("[data-copy-action");
    const successIcon = el.parentElement.querySelector("[data-copy-success");

    copyIcon.classList.remove("hidden");
    successIcon.classList.add("hidden");
  });
}

const Toggle = {
  mounted() {
    subscribeEventHandler(this.el);
  },
};

export default Toggle;
