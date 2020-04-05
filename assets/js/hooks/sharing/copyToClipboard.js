const subscribeEventHandler = (copyIcon) => {
  copyIcon.addEventListener("click", e => {
    const parent = copyIcon.parentElement;
    const target = parent.querySelector("[data-copy-target]");
    target.select();
    target.setSelectionRange(0, 99999);
    document.execCommand("copy");
    target.select();

    const successIcon = parent.querySelector("[data-copy-success]");
    successIcon.classList.toggle("hidden");
    copyIcon.classList.toggle("hidden");
  });
};

const CopyToClipboard = {
  mounted() {
    subscribeEventHandler(this.el);
  },
};

export default CopyToClipboard;
