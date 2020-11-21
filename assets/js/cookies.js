const displayCookies = () => {
  const cookiesBanner = document.getElementById("cookies-banner");
  const cookiesExpiration = Date.parse(localStorage.getItem("cookies-expiration"));

  if (!Number.isNaN(cookiesExpiration) && cookiesExpiration > Date.now()) {
    cookiesBanner.remove();
  } else {
    cookiesBanner.classList.remove("hidden");

    const closeCookiesBanner = document.getElementById("close-cookies-banner");
    closeCookiesBanner.addEventListener("click", () => {
      cookiesBanner.remove();

      const date = new Date();
      date.setMonth(date.getMonth() + 6);
      localStorage.setItem("cookies-expiration", date.toISOString());
    });
  }
}

export default displayCookies;
