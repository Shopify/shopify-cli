# frozen_string_literal: true

module Node
  module Messages
    MESSAGES = {
      node: {
        node_required_notice: "node is required to create an app project. Download at https://nodejs.org/en/download.",
        node_version_failure_notice: "Failed to get the current node version. Please make sure it is installed as " \
          "per the instructions at https://nodejs.org/en.",
        npm_required_notice: "npm is required to create an app project. Download at https://www.npmjs.com/get-npm.",
        npm_version_failure_notice: "Failed to get the current npm version. Please make sure it is installed as per " \
          "the instructions at https://www.npmjs.com/get-npm.",
      },
    }.freeze
  end
end
