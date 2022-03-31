# frozen_string_literal: true

require "project_types/theme/test_helper"

module Theme
  module Commands
    class ShareTest < MiniTest::Test
      def setup
        super
        @command = Theme::Command::Share.new(ctx)
      end

      def test_share
        ShopifyCLI::Theme::Theme.expects(:create_unpublished)
          .with(ctx, root: ".")
          .returns(theme)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme)
          .returns(syncer)

        syncer.expects(:start_threads)
        syncer.expects(:shutdown)
        syncer.expects(:upload_theme!)

        io = capture_io { @command.call([], "share") }.join

        expected_messages = [
          "Pushing theme files to Test theme (#1234) on test.myshopify.io",
          "Share your theme preview:",
          "https://test.myshopify.io/preview",
        ]

        expected_messages.each do |message|
          assert_includes(io, message)
        end
      end

      private

      def theme
        @theme ||= stub(
          "Theme",
          id: 1234,
          name: "Test theme",
          shop: "test.myshopify.io",
          editor_url: "https://test.myshopify.io/editor",
          preview_url: "https://test.myshopify.io/preview",
          live?: false,
        )
      end

      def syncer
        @syncer ||= stub(
          "Syncer",
          lock_io!: nil,
          unlock_io!: nil,
          has_any_error?: false
        )
      end

      def ctx
        @ctx ||= ShopifyCLI::Context.new
      end
    end
  end
end
