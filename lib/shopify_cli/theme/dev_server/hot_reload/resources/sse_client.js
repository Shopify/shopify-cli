class SSEClient {
  constructor(eventsUrl, eventHandler) {
    SSEClient.verifySSE();
    this.eventsUrl = eventsUrl;
    this.eventHandler = eventHandler;
  }
  static verifySSE() {
    if (typeof EventSource === "undefined") {
      console.error(
        "[HotReload] Error: SSE features are not supported. Try a different browser."
      );
    }

    console.log("[HotReload] Initializing...");
  }
  connect() {
    const eventSource = new EventSource(this.eventsUrl);
    eventSource.onmessage = (msg) => {
      this.handleMessage(msg);
    };

    eventSource.onopen = () => console.log("[HotReload] SSE connected.");

    eventSource.onclose = () => {
      console.log("[HotReload] SSE closed. Attempting to reconnect...");

      setTimeout(this.connect, 5000);
    };

    eventSource.onerror = () => {
      console.log("[HotReload] SSE closed.");
      eventSource.close();
    };
  }
  handleMessage(message) {
    const data = JSON.parse(message.data);
    if (data.reload_page) {
      HotReload.refreshPage([]);
      return;
    }
    this.eventHandler(data);
  }
}
