# frozen_string_literal: true
module Node
  class Command
    class Create < ShopifyCLI::Command::AppSubCommand
      prerequisite_task :ensure_authenticated
    end
  end
end
