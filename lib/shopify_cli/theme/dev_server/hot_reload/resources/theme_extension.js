(() => {
  const APP_BLOCK = "app-block",
    APP_EMBED_BLOCK = "app-embed-block";

  function querySelectHotReloadElements(handle) {
    // Gets all blocks (app and embed) with specified handle TODO: add app ID check here
    const blocks = Array.from(
      document.querySelectorAll(`[data-block-handle$='${handle}']`)
    );
    if (blocks.length) {
      const queryString = "shopify-section-template";
      const is_section = blocks[0].closest(`[id^=${queryString}]`) !== null;
      if (is_section)
        return [
          blocks.map((block) => block.closest(`[id^=${queryString}]`)),
          APP_BLOCK,
        ];

      return [blocks, APP_EMBED_BLOCK];
    }
    return [[], null];
  }

  function isRefreshRequired(files) {
    if (HotReload.isFullPageReloadMode()) {
      return true;
    }
    return files.some(
      (file) => !HotReload.isCSSFile(file) && !isBlockFile(file)
    );
  }

  function refreshFile(file) {
    if (HotReload.isCSSFile(file)) {
      HotReload.reloadCssFile(file);
      return;
    }

    let block = new Block(file); // minimize DOM queries
    if (block.valid()) return block.refresh();
  }

  function refreshPage(files) {
    HotReload.setHotReloadCookie(files);
    console.log("[HotReload] Refreshing entire page");
    window.location.reload();
  }

  function handleUpdate(data) {
    const modifiedFiles = data.modified;

    if (modifiedFiles === undefined) {
      return;
    }

    if (isRefreshRequired(modifiedFiles)) {
      refreshPage(modifiedFiles);
    } else {
      modifiedFiles.forEach(refreshFile);
    }
  }

  function isBlockFile(filename) {
    return new Block(filename).valid();
  }

  class Block {
    constructor(filename) {
      this.filename = filename;
      this.name = filename.split("/").pop().replace(".liquid", "");
      const [elements, type] = querySelectHotReloadElements(this.name);
      this.elements = elements;
      this.type = type;

      this.refreshElement = this.refreshElement.bind(this);
      this.refresh = this.refresh.bind(this);
      this.valid = this.valid.bind(this);
    }

    valid() {
      return this.filename.startsWith("blocks/") && this.elements.length > 0;
    }

    async refreshElement(element) {
      const url = new URL(window.location.href);
      let regex, key;
      if (this.type === APP_BLOCK) {
        regex = /^shopify-section-/;
        key = "section_id";
      } else {
        regex = /^shopify-block-/;
        key = "app_block_id";
      }
      const elementId = element.id.replace(regex, "");

      url.searchParams.append(key, elementId);

      HotReload.setHotReloadCookie([this.filename]);

      const response = await fetch(url);

      try {
        element.outerHTML = await response.text();
      } catch (e) {
        console.log(
          `[HotReload] Failed to reload ${this.name} ${this.type}: ${e.message}`
        );
      }
    }

    async refresh() {
      console.log(`[HotReload] Reloaded ${this.name} ${this.type}s`);
      this.elements.forEach(this.refreshElement);
    }
  }

  if (HotReload.isReloadModeActive()) {
    let client = new SSEClient("/hot-reload", handleUpdate);
    client.connect();
  }
})();
