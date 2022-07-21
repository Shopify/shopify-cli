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

  function querySelectHotReloadElements(filename, type) {
    const blocks = Array.from(document.querySelectorAll(`[data-block-handle$='${filename}']`));
    if (type === APP_BLOCK){
      return blocks.map((block) => block.closest(`[id^='shopify-section-template']`));
    }
    return blocks;
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
    return files.some((file) => !isCssFile(file) && !isAppBlockFile(file) && !isAppEmbedBlockFile(file));
  }

  function refreshFile(file) {
    if (isCssFile(file)) {
      reloadCssFile(file);
      return;
    }

    if (isAppBlockFile(file)) {
      reloadAppBlock(file);
      return;
    }

    if (isAppEmbedBlockFile(file)){
      reloadAppEmbedBlock(file);
    }
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
    let links = document.querySelectorAll(`link[href^="/assets"][href*="${filename}"][rel="stylesheet"]`);

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

  function isAppBlockFile(filename) {
    return new Block(filename, APP_BLOCK).valid();
  }

  function isAppEmbedBlockFile(filename) {
    return new Block(filename, APP_EMBED_BLOCK).valid();
  }

  function isSnippetFile(filename) {
    return filename.startsWith('snippets/');
  }

  function reloadAppBlock(filename) {
    new Block(filename, APP_BLOCK).refresh();
  }

  function reloadAppEmbedBlock(filename) {
    new Block(filename, APP_EMBED_BLOCK).refresh();
  }

  class Block {
    constructor(filename, type) {
      this.filename = filename;
      this.type = type;
      this.name = filename.split('/').pop().replace('.liquid', '');
      this.elements = querySelectHotReloadElements(this.name, type);
    }

    valid(){
      return this.filename.startsWith('blocks/') && this.elements.length > 0;
    }

    async refreshElement(element) {
      const url = new URL(window.location.href);
      let regex, key;
      if (this.type === APP_BLOCK){
        regex = new RegExp(`\\^shopify-section-template/`);
        key = "section_id";
      }else{
        regex = new RegExp(`\\^shopify-block-/`);
        key = "app_embed_block_id";
      }
      const elementId = element.id.replace(regex, '');

      url.searchParams.append(key, elementId);

      setHotReloadCookie([this.filename]);

      const response = await fetch(url);

      try {
        if (response.headers.get('x-templates-from-params') === '1') {
          element.outerHTML = await response.text();
        } else {
          window.location.reload();

          console.log(`[HotReload] Hot-reloading not supported, fully reloading ${this.name} ${this.type}`);
        }

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
