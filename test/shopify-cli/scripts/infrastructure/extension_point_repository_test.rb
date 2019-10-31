# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository do
  subject { ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository.new(script_service) }
  let(:script_service) { MiniTest::Mock.new }

  describe ".get_extension_point" do
    let(:extension_points) do
      [
        {
          "name" => remote_extension,
          "schema" => discount_schema,
          "types" => remote_types,
          "script_example" => script_example,
        },
        {
          "name" => invalid_extension,
          "schema" => discount_schema,
          "script_example" => script_example,
        },
      ]
    end
    let(:discount_schema) do
      <<~HEREDOC
        type Money {
          subunits: Int!
          iso_currency: String!
        }

        input MoneyInput {
          subunits: Int!
          iso_currency: String!
        }

        input MultiCurrencyRequest {
          money: MoneyInput!
          presentment_currency: String
          shop_currency: String
        }

        type Query {
          run(root: MultiCurrencyRequest!): Money!
        }

        schema { query: Query }
      HEREDOC
    end
    let(:remote_types) do
      <<~HEREDOC
        import { Slice, Str } from "../shopify_runtime_types";


        @unmanaged
        export class Money {
          public subunits: i32;
          public iso_currency: Str;

          constructor(subunits: i32, iso_currency: String) {
            this.subunits = subunits;
            this.iso_currency = Str.from(iso_currency);
          }
        }

        @unmanaged
        export class MultiCurrencyRequest {
          public money: MoneyInput;
          public presentment_currency: Str;
          public shop_currency: Str;

          constructor(money: MoneyInput, presentment_currency: String, shop_currency: String) {
            this.money = money;
            this.presentment_currency = Str.from(presentment_currency);
            this.shop_currency = Str.from(shop_currency);
          }
        }

        @unmanaged
        export class MoneyInput {
          public subunits: i32;
          public iso_currency: Str;

          constructor(subunits: i32, iso_currency: String) {
            this.subunits = subunits;
            this.iso_currency = Str.from(iso_currency);
          }
        }
      HEREDOC
    end
    let(:script_example) do
      <<~HEREDOC
        import { Slice, Str } from "./shopify_runtime_types";
        import { MultiCurrencyRequest, Money } from "./types/vanity_pricing";
        import { Config } from "./configuration/configuration";

        export function run(req: MultiCurrencyRequest, config: Config): Money {
            if (req.money.subunits % 10 >= 5) {
                return new Money(req.money.subunits + 10 - req.money.subunits % 10, req.money.iso_currency);
            } else {
                return new Money(req.money.subunits - req.money.subunits % 10, req.money.iso_currency);
            }
        }
      HEREDOC
    end
    let(:script_examples) do
      {
        "ts" => script_example,
        "js" => nil,
        "json" => nil,
      }
    end

    let(:remote_extension) { "discount" }
    let(:invalid_extension) { "bad" }
    let(:extension) { remote_extension }

    before do
      script_service.expect(:fetch_extension_points, extension_points)
    end

    describe "if the right extension point exists" do
      it "should return valid ExtensionPoint" do
        extension_point = subject.get_extension_point(extension)
        assert_equal discount_schema, extension_point.schema
        assert_equal extension, extension_point.type
        assert_equal script_examples, extension_point.example_scripts
        assert_equal remote_types, extension_point.sdk_types
      end
    end

    describe "if the right extension point does not exist" do
      let(:extension) { "bogus" }
      it "should raise an ArgumentError" do
        err = assert_raises ShopifyCli::ScriptModule::Domain::InvalidExtensionPointError do
          subject.get_extension_point(extension)
        end
        assert_equal "Extension point #{extension} cannot be found", err.message
      end
    end

    describe "if the right extension point exist, but it's misconfigured" do
      let(:extension) { invalid_extension }
      it "should raise an ArgumentError" do
        err = assert_raises ShopifyCli::ScriptModule::Domain::InvalidExtensionPointError do
          subject.get_extension_point(extension)
        end
        assert_equal "Extension point #{extension} cannot be found", err.message
      end
    end
  end
end
