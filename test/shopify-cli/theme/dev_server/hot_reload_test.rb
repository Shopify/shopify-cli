# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/dev_server"
require "rack/mock"

class HotReloadTest < Minitest::Test
  def setup
    super
    config = ShopifyCli::Theme::DevServer::Config.from_path(ShopifyCli::ROOT + "/test/fixtures/theme")
    @ctx = TestHelpers::FakeContext.new(root: config.root)
    @theme = ShopifyCli::Theme::DevServer::Theme.new(config)
    @watcher = ShopifyCli::Theme::DevServer::Watcher.new(@ctx, @theme)
  end

  def test_hot_reload_js_injected_if_html_request
    html = <<~HTML
      <html>
        <head></head>
        <body>
          <h1>Hello</h1>
        </body>
      </html>
    HTML

    reload_js = File.read(File.expand_path("lib/shopify-cli/theme/dev_server/hot-reload.js", ShopifyCli::ROOT))
    reload_script = "<script>\n#{reload_js}</script>"
    expected_html = <<~HTML
      <html>
        <head></head>
        <body>
          <h1>Hello</h1>
        #{reload_script}
      </body>
      </html>
    HTML

    response = serve(html, headers: { "content-type" => "text/html" })

    assert_equal(expected_html, response)
  end

  def test_does_not_inject_hot_reload_js_for_non_html_responses
    css = <<~CSS
      .body { color: red }
    CSS

    response = serve(css, headers: { "content-type" => "text/css" })

    assert_equal(css, response)
  end

  def test_streams_on_hot_reload_path
    ShopifyCli::Theme::DevServer::SSE::Stream.any_instance.expects(:each).yields("")
    serve(path: "/hot-reload")
  end

  def test_broadcasts_watcher_events
    modified = ["style.css"]
    ShopifyCli::Theme::DevServer::SSE::Streams.any_instance
      .expects(:broadcast)
      .with(JSON.generate(modified: modified))

    app = -> { [200, {}, []] }
    ShopifyCli::Theme::DevServer::HotReload.new(app, @theme, @watcher)

    @watcher.changed
    @watcher.notify_observers(modified, [], [])
  end

  private

  def serve(response_body = "", path: "/", headers: {})
    app = lambda do |_env|
      [200, headers, [response_body]]
    end
    stack = ShopifyCli::Theme::DevServer::HotReload.new(app, @theme, @watcher)
    request = Rack::MockRequest.new(stack)
    request.get(path).body
  end
end
