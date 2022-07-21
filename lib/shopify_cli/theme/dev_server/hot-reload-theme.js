(() => {
  function verifySSE() {
    if (typeof (EventSource) === "undefined") {
      console.error("[HotReload] Error: SSE features are not supported. Try a different browser.");
    }
  }

  console.log("[HotReload] Initializing...");

  verifySSE();
})();

(() => {
  function connect() {
    const eventSource = new EventSource('/hot-reload');

    eventSource.onmessage = onMessage;

    eventSource.onopen = () => console.log('[HotReload] SSE connected.');

    eventSource.onclose = () => {
      console.log('[HotReload] SSE closed. Attempting to reconnect...');

      setTimeout(connect, 5000);
    }

    eventSource.onerror = () => eventSource.close();
  }

  function sectionNamesByType(type) {
    const namespace = window.__SHOPIFY_CLI_ENV__;
    return namespace.section_names_by_type[type] || [];
  }

  function reloadMode() {
    const namespace = window.__SHOPIFY_CLI_ENV__;
    return namespace.mode;
  }

  function querySelectDOMSections(idSuffix) {
    const elements = document.querySelectorAll(`[id^='shopify-section'][id$='${idSuffix}']`);
    return Array.from(elements);
  }

  function fetchDOMSections(name) {
    const domSections = sectionNamesByType(name).flatMap((n) => querySelectDOMSections(n));

    if (domSections.length > 0) {
      return domSections;
    }

    return querySelectDOMSections(name);
  }

  function isFullPageReloadMode() {
    return reloadMode() === 'full-page';
  }

  function isReloadModeActive() {
    return reloadMode() !== 'off';
  }

  function isRefreshRequired(files) {
    if (isFullPageReloadMode()) {
      return true;
    }
    return files.some((file) => !isCssFile(file) && !isSectionFile(file));
  }

  function refreshFile(file) {
    if (isCssFile(file)) {
      reloadCssFile(file);
      return;
    }

    if (isSectionFile(file)) {
      reloadSection(file);
      return;
    }
  }

  function setHotReloadCookie(files) {
    var date = new Date();

    // Hot reload cookie expires in 3 seconds
    date.setSeconds(date.getSeconds() + 3);

    var sections = files.join(',');
    var expires = date.toUTCString();

    document.cookie = `hot_reload_sections=${sections}; expires=${expires}; path=/`;
  }

  function refreshPage(files) {
    setHotReloadCookie(files);
    console.log('[HotReload] Refreshing entire page');
    window.location.reload();
  }

  function onMessage(message) {
    const data = JSON.parse(message.data);
    if (data.reload_page) {
      refreshPage([]);
      return;
    }

    handleUpdate(data);
  }

  function handleUpdate(data) {
    var modifiedFiles = data.modified;

    if (modifiedFiles === undefined) {
      return;
    }

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

  function isSectionFile(filename) {
    return new Section(filename).valid();
  }

  function reloadSection(filename) {
    new Section(filename).refresh();
  }

  class Section {
    constructor(filename) {
      this.filename = filename;
      this.name = filename.split('/').pop().replace('.liquid', '');
      this.elements = fetchDOMSections(this.name);
    }

    valid() {
      return this.filename.startsWith('sections/') && this.elements.length > 0;
    }

    async refreshElement(element) {

      const sectionId = element.id.replace(/^shopify-section-/, '');
      const url = new URL(window.location.href);

      url.searchParams.append('section_id', sectionId);

      const response = await fetch(url);

      try {
        if (response.headers.get('x-templates-from-params') == '1') {
          const html = await response.text();
          element.outerHTML = html;
        } else {
          window.location.reload();

          console.log(`[HotReload] Hot-reloading not supported, fully reloading ${this.name} section`);
        }

      } catch (e) {
        console.log(`[HotReload] Failed to reload ${this.name} section: ${e.message}`);
      }
    }

    async refresh() {
      console.log(`[HotReload] Reloaded ${this.name} sections`);
      this.elements.forEach(this.refreshElement);
    }
  }

  if (isReloadModeActive()) {
    connect();
  }
})();
