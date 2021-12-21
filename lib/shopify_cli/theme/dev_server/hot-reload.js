(() => {
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

  connect();

  function isRefreshRequired(files) {
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

  function handleUpdate(message) {
    var data = JSON.parse(message.data);
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
    let link = document.querySelector(`link[href^="/assets"][href*="${filename}"][rel="stylesheet"]`);

    if (!link) {
      console.log(`[HotReload] Could not find link for stylesheet ${filename}`);
    } else {
      link.href = new URL(link.href).pathname + `?v=${Date.now()}`;
      console.log(`[HotReload] Reloaded stylesheet ${filename}`);
    }
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
      this.element = document.querySelector(`[id^='shopify-section'][id$='${this.name}']`);
    }

    valid() {
      return this.filename.startsWith('sections/') && this.element;
    }

    async refresh() {
      var url = new URL(window.location.href);
      url.searchParams.append('section_id', this.name);

      try {
        const response = await fetch(url);
        if (response.headers.get('x-templates-from-params') == '1') {
          const html = await response.text();
          this.element.outerHTML = html;

          console.log(`[HotReload] Reloaded ${this.name} section`);
        } else {
          window.location.reload()

          console.log(`[HotReload] Hot-reloading not supported, fully reloading ${this.name} section`);
        }

      } catch (e) {
        console.log(`[HotReload] Failed to reload ${this.name} section: ${e.message}`);
      }
    }
  }
})();
