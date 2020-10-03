const displayCookies = () => {
  const cookiesBanner = document.getElementById("cookies-banner");

  if (sessionStorage.getItem("cookies-accept")) {
    cookiesBanner.remove();
  } else {
    cookiesBanner.classList.remove("hidden");

    const closeCookiesBanner = document.getElementById("close-cookies-banner");
    closeCookiesBanner.addEventListener("click", () => {
      cookiesBanner.remove();
      sessionStorage.setItem("cookies-accept", true);
    });
  }
}

export default displayCookies;
