# frozen_string_literal: true

module Extension
  module Errors
    class ExtensionError < StandardError; end
    class InvalidFilenameError < ExtensionError; end
    class BundleTooLargeError < ExtensionError; end
  end
end
