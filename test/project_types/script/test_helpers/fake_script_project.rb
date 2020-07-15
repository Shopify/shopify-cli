module TestHelpers
  class FakeScriptProject < FakeProject
    property :extension_point_type
    property :script_name
    property :language

    def file_name
      "script.#{language}"
    end

    def source_file
      "src/#{file_name}"
    end

    def source_path
      "#{script_name}/#{source_file}"
    end
  end
end
