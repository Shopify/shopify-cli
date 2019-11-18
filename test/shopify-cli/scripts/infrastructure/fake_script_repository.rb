module ShopifyCli
  module ScriptModule
    module Infrastructure
      class FakeScriptRepository
        def initialize
          @cache = {}
        end

        def create_script(language, extension_point, script_name)
          id = "#{language}/#{extension_point.type}/#{script_name}"
          @cache[id] = ShopifyCli::ScriptModule::Domain::Script.new(
            script_name, extension_point, language, extension_point.schema
          )
        end

        def get_script(language, extension_point_type, script_name)
          id = "#{language}/#{extension_point_type}/#{script_name}"

          if @cache.key?(id)
            @cache[id]
          else
            raise Domain::ScriptNotFoundError.new(extension_point_type, script_name)
          end
        end
      end
    end
  end
end
