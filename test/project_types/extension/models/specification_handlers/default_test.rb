# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Models
    module SpecificationHandlers
      class DefaultTest < MiniTest::Test
        include ExtensionTestHelpers::TestExtensionSetup

        def setup
          super
          @default_spec = Default.new(specification)
        end

        def test_tagline_returns_empty_string_if_not_defined_in_content
          @default_spec.stubs(:identifier).returns("INVALID")

          assert_equal "", @default_spec.tagline
        end

        def test_serve
          context = mock
          argo_runtime = mock
          argo_serve = mock

          @default_spec.stubs(:argo_runtime).with(context).returns(argo_runtime)

          Features::ArgoServe
            .expects(:new)
            .with(
              specification_handler: @default_spec,
              argo_runtime: argo_runtime,
              context: context,
              port: 9999,
              tunnel_url: "url://tunnel_url",
              resource_url: "url://resource_url"
            )
            .returns(argo_serve)

          argo_serve.expects(:call)

          @default_spec.serve(
            context: context,
            port: 9999,
            tunnel_url: "url://tunnel_url",
            resource_url: "url://resource_url",
            other: "other property",
          )
        end

        def test_valid_extension_contexts_returns_empty_array
          assert_empty(@default_spec.valid_extension_contexts)
        end

        def test_extension_context_returns_nil
          assert_nil(@default_spec.extension_context(@context))
        end

        def test_graphql_identifier_is_upcased
          assert_equal specification.identifier.upcase, @default_spec.graphql_identifier
        end

        def test_name_defaults_to_specification_name
          assert_equal "Test Extension", @test_extension_type.name
        end

        def test_name_can_be_overriden_using_messages
          Messages::TYPES.merge!({
            test_extension: {
              name: "Overridden Name",
            },
          })
          assert_equal "Overridden Name", @test_extension_type.name
        ensure
          Messages::TYPES.delete(:test_extension)
        end

        private

        def specification
          Models::Specification.new(identifier: "test_extension")
        end
      end
    end
  end
end
