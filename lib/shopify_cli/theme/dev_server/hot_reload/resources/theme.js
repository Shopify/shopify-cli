(() => {
  function sectionNamesByType(type) {
    const namespace = window.__SHOPIFY_CLI_ENV__;
    return namespace.section_names_by_type[type] || [];
  }

  function querySelectDOMSections(idSuffix) {
    const elements = document.querySelectorAll(
      `[id^='shopify-section'][id$='${idSuffix}']`
    );
    return Array.from(elements);
  }

  function fetchDOMSections(name) {
    const domSections = sectionNamesByType(name).flatMap((n) =>
      querySelectDOMSections(n)
    );

    if (domSections.length > 0) {
      return domSections;
    }

    return querySelectDOMSections(name);
  }

  function isRefreshRequired(files) {
    if (HotReload.isFullPageReloadMode()) {
      return true;
    }
    return files.some(
      (file) => !HotReload.isCSSFile(file) && !isSectionFile(file)
    );
  }

  function refreshFile(file) {
    if (HotReload.isCSSFile(file)) {
      HotReload.reloadCssFile(file);
      return;
    }

    if (isSectionFile(file)) {
      reloadSection(file);
    }
  }

  function handleUpdate(data) {
    const modifiedFiles = data.modified;

    if (modifiedFiles === undefined) {
      return;
    }

    if (isRefreshRequired(modifiedFiles)) {
      HotReload.refreshPage(modifiedFiles);
    } else {
      modifiedFiles.forEach(refreshFile);
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
      this.name = filename.split("/").pop().replace(".liquid", "");
      this.elements = fetchDOMSections(this.name);
    }

    valid() {
      return this.filename.startsWith("sections/") && this.elements.length > 0;
    }

    async refreshElement(element) {
      const sectionId = element.id.replace(/^shopify-section-/, "");
      const url = new URL(window.location.href);

      url.searchParams.append("section_id", sectionId);

      const response = await fetch(url);

      try {
        if (response.headers.get("x-templates-from-params") === "1") {
          element.outerHTML = await response.text();
        } else {
          window.location.reload();

          console.log(
            `[HotReload] Hot-reloading not supported, fully reloading ${this.name} section`
          );
        }
      } catch (e) {
        console.log(
          `[HotReload] Failed to reload ${this.name} section: ${e.message}`
        );
      }
    }

    async refresh() {
      console.log(`[HotReload] Reloaded ${this.name} sections`);
      this.elements.forEach(this.refreshElement);
    }
  }

  if (HotReload.isReloadModeActive()) {
    let client = new SSEClient("/hot-reload", handleUpdate);
    client.connect();
  }
})();
