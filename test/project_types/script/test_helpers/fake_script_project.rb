module TestHelpers
  class FakeScriptProject < FakeProject
    property :extension_point_type
    property :script_name
    property :language

    def source_file
      "src/#{file_name}"
    end

    def file_name
      "script.#{language}"
    end
  end
end
