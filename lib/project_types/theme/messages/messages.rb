# frozen_string_literal: true
module Theme
  module Messages
    MESSAGES = {
      ensure_themekit_installed: {
        downloading: "Downloading Themekit %s",
        failed: "Download failed",
        successful: "Themekit installed successfully",
        unsuccessful: "Unable to verify download digest",
        verifying: "Verifying download...",
      },
    }.freeze
  end
end
