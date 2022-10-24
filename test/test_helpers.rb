# frozen_string_literal: true
module TestHelpers
  autoload :Command, "test_helpers/command"
  autoload :Constants, "test_helpers/constants"
  autoload :FakeTask, "test_helpers/fake_task"
  autoload :FakeContext, "test_helpers/fake_context"
  autoload :FakeDB, "test_helpers/fake_db"
  autoload :FakeFS, "test_helpers/fake_fs"
  autoload :FakeProject, "test_helpers/fake_project"
  autoload :FakeUI, "test_helpers/fake_ui"
  autoload :Heroku, "test_helpers/heroku"
  autoload :Partners, "test_helpers/partners"
  autoload :Project, "test_helpers/project"
  autoload :Schema, "test_helpers/schema"
  autoload :Shopifolk, "test_helpers/shopifolk"
  autoload :Singleton, "test_helpers/singleton"
  autoload :TemporaryDirectory, "test_helpers/temporary_directory"
end
