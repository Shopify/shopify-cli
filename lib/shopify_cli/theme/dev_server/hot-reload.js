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

  let nonDynamicFileChanged = false;
  function handleUpdate(message) {
    var data = JSON.parse(message.data);

    if(data.modified) {
      data.modified.forEach(file => {
        if (isCssFile(file)) {
          reloadCssFile(file)
        } else if (isSectionFile(file)) {
          reloadSection(file);
        } else {
          nonDynamicFileChanged = true;
        }
      });
    }

    if(nonDynamicFileChanged) {
      console.log(`[HotReload] Refreshing entire page, waiting for file uploads`);
    }
    
    if(nonDynamicFileChanged && data.uploadComplete) {
      window.location.reload();
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
          nonDynamicFileChanged = true;

          console.log(`[HotReload] Hot-reloading not supported, fully reloading ${this.name} section`);
        }

      } catch (e) {
        console.log(`[HotReload] Failed to reload ${this.name} section: ${e.message}`);
      }
    }
  }
})();
