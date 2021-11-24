(() => {
  class SectionReloadEvent extends Event {
    constructor(filename, name, id) {
      super('shopify:hot:section', { bubbles: true, cancelable: false });
      this.filename = filename;
      this.name = name;
      this.id = id;
    }
  }

  class StylesheetReloadEvent extends Event {
    constructor(filename, links) {
      super('shopify:hot:stylesheet', { bubbles: true, cancelable: false });
      this.filename = filename;
      this.links = links;
    }
  }

  // Extracts the sections name from a given filename.
  const sectionGetNameFromFilename = (filename) => {
    return filename.split('/').pop().replace('.liquid', '');
  }

  // Queries all sections on the page that use a given name.
  const sectionGetElementsForName = (name) => {
    return document.querySelectorAll(`[id^='shopify-section'][id$='${name}']`);
  }

  // Returns the sections ID from the HTML element itself.
  const sectionGetIdFromElement = (element) => {
    return element.id.replace(/shopify-section-/g, '');
  }

  // Validates whether or not a filename can be used to reload any section.
  const hotReloadSectionIsValid = (filename) => {
    return (
      filename.startsWith('sections/') &&
      sectionGetElementsForName(sectionGetNameFromFilename(filename)).length > 0
    );
  }

  // Reloads all sections that make use of a changed section file.
  const hotReloadSection = (filename) => {
    const name = sectionGetNameFromFilename(filename);
    const sections = sectionGetElementsForName(name);

    return Promise.all([ ...sections ].map(async element => {
      const id = sectionGetIdFromElement(element);
      const url = new URL(window.location.href);
      url.searchParams.append('section_id', id || name);

      try {
        const response = await fetch(url);
        if (response.headers.get('x-templates-from-params') == '1') {
          const html = await response.text();
          const parent = element.parentElement || document.documentElement;

          // Replace contents
          element.outerHTML = html;

          // Dispatch event.
          const evt = new SectionReloadEvent(filename, name, id);
          parent.dispatchEvent(evt);
          console.log(`[HotReload] Reloaded ${id} section`);
        } else {
          window.location.reload();
          console.log(`[HotReload] Hot-reloading not supported, fully reloading ${id} section`);
        }
      } catch (e) {
        console.log(`[HotReload] Failed to reload ${id} section: ${e.message}`);
      }
    }));
  }

  // Validates if a filename is a CSS file or not.
  const hotReloadIsCssFile = (filename) => filename.endsWith('.css');

  // Reload a given CSS file.
  const hotReloadCssFile = (filename) => {
    // Find all stylesheets starting with /assets (locally-served only) and containing the filename.
    const links = document.querySelectorAll(`link[href^="/assets"][href*="${filename}"][rel="stylesheet"]`);
    if (!links.length) {
      console.log(`[HotReload] Could not find link for stylesheet ${filename}`);
      return;
    }

    // Update their link refs
    links.forEach(link => {
      link.href = new URL(link.href).pathname + `?v=${Date.now()}`;
    });

    // Dispatch event.
    document.documentElement.dispatchEvent(new StylesheetReloadEvent(
      filename, links
    ));
    console.log(`[HotReload] Reloaded stylesheet`, filename);
  }

  // Handler for when event messages are received.
  const hotReloadHandleMesage = (message) => {
    var data = JSON.parse(message.data);

    // Assume only one file is modified at a time
    var modified = data.modified[0];

    if (hotReloadIsCssFile(modified)) {
      hotReloadCssFile(modified)
    } else if (hotReloadSectionIsValid(modified)) {
      hotReloadSection(modified);
    } else {
      console.log(`[HotReload] Refreshing entire page`);
      window.location.reload();
    }
  }

  // Method to begin connecting to the hot reload source.
  const hotReloadConnect = () => {
    const eventSource = new EventSource('/hot-reload');

    eventSource.onmessage = hotReloadHandleMesage;
    eventSource.onopen = () => console.log('[HotReload] SSE connected.');
    eventSource.onclose = () => {
      console.log('[HotReload] SSE closed. Attempting to reconnect...');
      setTimeout(connect, 5000);
    };
    eventSource.onerror = () => eventSource.close();
  }

  // Connect to the event target.
  hotReloadConnect();
})();
