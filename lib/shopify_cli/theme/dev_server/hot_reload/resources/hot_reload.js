class HotReload {
  static reloadMode = () => {
    const namespace = window.__SHOPIFY_CLI_ENV__;
    return namespace.mode;
  };
  static isFullPageReloadMode = () => {
    return HotReload.reloadMode() === "full-page";
  };
  static isReloadModeActive = () => {
    return HotReload.reloadMode() !== "off";
  };
  static setHotReloadCookie = (files) => {
    const date = new Date();

    // Hot reload cookie expires in 3 seconds
    date.setSeconds(date.getSeconds() + 3);

    const sections = files.join(",");
    const expires = date.toUTCString();

    document.cookie = `hot_reload_files=${sections}; expires=${expires}; path=/`;
  };
  static refreshPage = (files) => {
    HotReload.setHotReloadCookie(files);
    console.log("[HotReload] Refreshing entire page");
    window.location.reload();
  };
  static isCSSFile = (filename) => {
    return filename.endsWith(".css");
  };
  static reloadCssFile = (filename) => {
    // Find a stylesheet link starting with /assets (locally-served only) containing the filename
    let links = document.querySelectorAll(
      `link[href^="/assets"][href*="${filename}"][rel="stylesheet"]`
    );

    Array.from(links).forEach((link) => {
      if (!link) {
        console.log(
          `[HotReload] Could not find link for stylesheet ${filename}`
        );
      } else {
        link.href = new URL(link.href).pathname + `?v=${Date.now()}`;
        console.log(`[HotReload] Reloaded stylesheet ${filename}`);
      }
    });
  };
}
