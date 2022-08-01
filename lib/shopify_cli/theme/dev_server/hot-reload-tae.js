
(() => {
  const APP_BLOCK = 'app-block', APP_EMBED_BLOCK = 'app-embed-block';

  function connect() {
    const eventSource = new EventSource('/hot-reload');

    eventSource.onmessage = handleUpdate;

    eventSource.onopen = () => console.log('[HotReload] SSE connected.');

    eventSource.onclose = () => {
      console.log('[HotReload] SSE closed. Attempting to reconnect...');

      setTimeout(connect, 5000);
    }

    eventSource.onerror = () => eventSource.close();
  }

  function reloadMode() {
    const namespace = window.__SHOPIFY_CLI_ENV__;
    return namespace.mode;
  }

  function appID(){
    const namespace = window.__SHOPIFY_CLI_ENV__;
    return namespace.app_id; // returns the app ID of the extension being served
  }

  function querySelectHotReloadElements(handle) {
    // Gets all blocks (app and embed) with specified handle TODO: add app ID check here
    const blocks = Array.from(document.querySelectorAll(`[data-block-handle$='${handle}']`));
    if (blocks.length){
      const queryString = 'shopify-section-template';
      const is_section = blocks[0].closest(`[id^=${queryString}]`) !== null;
      if (is_section) return [blocks.map((block) => block.closest(`[id^=${queryString}]`)), APP_BLOCK];

      return [blocks, APP_EMBED_BLOCK];
    }
    return [[], null];
  }

  function isFullPageReloadMode(){
    return reloadMode() === 'full-page';
  }

  function isReloadModeActive(){
    return reloadMode() !== 'off';
  }

  function isRefreshRequired(files) {
    if (isFullPageReloadMode()) {
      return true;
    }
    return files.some((file) => !isCssFile(file) && !isBlockFile(file));
  }

  function refreshFile(file) {
    if (isCssFile(file)) {
      reloadCssFile(file);
      return;
    }

    let block = new Block(file); // minimize DOM queries
    if (block.valid()) return block.refresh();
  }

  function setHotReloadCookie(files) {
    var date = new Date();

    // Hot reload cookie expires in 3 seconds
    date.setSeconds(date.getSeconds() + 3);

    var elements = files.join(',');
    var expires = date.toUTCString();

    document.cookie = `hot_reload_files=${elements}; expires=${expires}; path=/`;
  }

  function refreshPage(files) {
    setHotReloadCookie(files);
    console.log('[HotReload] Refreshing entire page');
    window.location.reload();
  }

  function handleUpdate(message) {
    let data = JSON.parse(message.data);
    var modifiedFiles = data.modified;

    if (isRefreshRequired(modifiedFiles)) {
      refreshPage(modifiedFiles);
    } else {
      modifiedFiles.forEach(refreshFile);
    }
  }

  function isCssFile(filename) {
    return filename.endsWith('.css');
  }

  function reloadCssFile(filename) {
    // Find a stylesheet link starting with /assets (locally-served only) containing the filename
    let links = document.querySelectorAll(`link[href^="/assets"][href*="${filename}"][rel="stylesheet"][data-app-id=${appID()}]`);

    Array.from(links).forEach((link) => {
      if (!link) {
        console.log(`[HotReload] Could not find link for stylesheet ${filename}`);
      } else {
        console.log(link)
        link.href = new URL(link.href).pathname + `?v=${Date.now()}`;
        console.log(`[HotReload] Reloaded stylesheet ${filename}`);
      }
    });
  }

  function isBlockFile(filename) {
    return new Block(filename).valid();
  }

  class Block {
    constructor(filename) {
      this.filename = filename;
      this.name = filename.split('/').pop().replace('.liquid', '');
      const [elements, type] = querySelectHotReloadElements(this.name);
      this.elements = elements;
      this.type = type;

      this.refreshElement = this.refreshElement.bind(this);
      this.refresh = this.refresh.bind(this);
      this.valid = this.valid.bind(this);
    }

    valid(){
      return this.filename.startsWith('blocks/') && this.elements.length > 0;
    }

    async refreshElement(element) {
      const url = new URL(window.location.href);
      let regex, key;
      if (this.type === APP_BLOCK){
        regex = /^shopify-section-/;
        key = "section_id";
      }else{
        regex = /^shopify-block-/;
        key = "app_embed_block_id";
      }
      const elementId = element.id.replace(regex, '');

      url.searchParams.append(key, elementId);

      setHotReloadCookie([this.filename]);

      const response = await fetch(url);

      try {
        element.outerHTML = await response.text();
      } catch (e) {
        console.log(`[HotReload] Failed to reload ${this.name} ${this.type}: ${e.message}`);
      }
    }

    async refresh() {
      console.log(`[HotReload] Reloaded ${this.name} ${this.type}s`);
      this.elements.forEach(this.refreshElement);
    }
  }

  if (isReloadModeActive()) {
    connect();
  }
})();