module Extension
  module Specifications
    autoload :CreateHandler, Project.project_filepath('specifications/create_handler')
    autoload :FakeDataRepository, Project.project_filepath('specifications/fake_data_repository')
    autoload :InstantiateFromApiResponse, Project.project_filepath('specifications/instantiate_from_api_response')
    autoload :PlaceholderRepository, Project.project_filepath('specifications/placeholder_repository')
    autoload :Specification, Project.project_filepath('specifications/specification')

    module Handlers
      autoload :Default, Project.project_filepath('specifications/handlers/default')
    end

    module_function

    def exists?(identifier, repository = self.repository)
      repository
        .get(identifier)
        .yield_ok { |specification| !!specification }
        .ok_value_or_else { |e| raise e }
    end

    def each(repository = self.repository, &iterator)
      return to_enum(:each) if iterator.nil?

      repository
        .all
        .and_then(&InstantiateFromApiResponse) 
        .and_then(&CreateHandler)
        .ok_value_or_else { |e| raise e }
        .each(&iterator)
    end

    def [](identifier, repository = self.repository)
      repository
        .get(identifier)
        .and_then(&InstantiateFromApiResponse)
        .and_then(&CreateHandler)
        .ok_value_or_else { |e| raise e }
    end

    def repository
      @repository || FakeDataRepository.new
    end

    def repository=(repository)
      @repository = repository
    end
  end
end
