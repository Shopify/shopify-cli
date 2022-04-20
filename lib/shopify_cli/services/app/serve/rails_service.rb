module ShopifyCLI
  module Services
    module App
      module Serve
        class RailsService < ServeService
          def call
            generate_url

            CLI::UI::Frame.open(context.message("core.app.serve.running_server")) do
              original_env = JSON.parse(ENV["ORIGINAL_ENV"] || "{}")
              env = original_env.merge(ShopifyCLI::Project.current.env.to_h)
              env.delete("HOST") if context.ruby_gem_version("shopify_app") < ::Semantic::Version.new("19.0.0")
              env["PORT"] = port.to_s
              env["GEM_PATH"] =
                [env["GEM_PATH"], Rails::Gem.gem_path(context)].compact
                  .join(CLI::UI::OS.current.path_separator)
              if context.windows?
                context.system("ruby bin\\rails server", env: env)
              else
                context.system("bin/rails server", env: env)
              end
            end
          end
        end
      end
    end
  end
end
