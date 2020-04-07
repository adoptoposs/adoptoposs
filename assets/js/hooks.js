import InfiniteScroll from "./hooks/infiniteScroll";
import Sharing from "./hooks/sharing";

const Hooks = {
  InfiniteScroll: InfiniteScroll,
  SharingReset: Sharing.ResetOnClose,
  SharingCopy: Sharing.CopyToClipboard,
};

export default Hooks;

