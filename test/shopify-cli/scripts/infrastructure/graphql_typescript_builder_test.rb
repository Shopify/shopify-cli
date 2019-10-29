# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::GraphQLTypeScriptBuilder do
  let(:builder) { ShopifyCli::ScriptModule::Infrastructure::GraphQLTypeScriptBuilder.new }
  describe ".build" do
    subject { builder.build(schema, "Do not change header") }

    describe "when schema consists of only input and output that is an array" do
      let(:schema) do
        "type Money {
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
          discount: [Discount]
        }

        input Discount {
          value: Int!
        }

        type Query {
          run(root: MultiCurrencyRequest!): [Money!]
        }

        schema { query: Query }"
      end

      it "should generate the ts file with classes for input and helper plural output class encapsulating Slice" do
        expected_output =
          <<~HEREDOC
            /*
             Do not change header,
             */
            import { Slice, Str, ID, Int, Float } from \"../shopify_runtime_types\";

            @unmanaged
            export class Moneys extends Slice<Money> {
              static fromArray(arr: Array<Money>): Moneys {
                return <Moneys>Slice.fromArray<Money>(arr);
              }

              @inline
              static from(arr: Array<Money>): Moneys {
                return Moneys.fromArray(arr);
              }
            }

            @unmanaged
            export class Money {
              public subunits: Int;
              public iso_currency: Str;

              constructor(subunits: Int, iso_currency: String) {
                this.subunits = subunits;
                this.iso_currency = Str.from(iso_currency);
              }
            }

            @unmanaged
            export class MultiCurrencyRequest {
              public money: MoneyInput;
              public presentment_currency: Str;
              public shop_currency: Str;
              public discount: Slice<Discount>;

              constructor(money: MoneyInput, presentment_currency: String, shop_currency: String, discount: Array<Discount>) {
                this.money = money;
                this.presentment_currency = Str.from(presentment_currency);
                this.shop_currency = Str.from(shop_currency);
                this.discount = Slice.from<Discount>(discount);
              }
            }

            @unmanaged
            export class MoneyInput {
              public subunits: Int;
              public iso_currency: Str;

              constructor(subunits: Int, iso_currency: String) {
                this.subunits = subunits;
                this.iso_currency = Str.from(iso_currency);
              }
            }

            @unmanaged
            export class Discount {
              public value: Int;

              constructor(value: Int) {
                this.value = value;
              }
            }

            HEREDOC

        assert_equal expected_output, subject
      end
    end

    describe "when schema consists of both input and configuration" do
      let(:schema) do
        "type Query  {
          run(input: Checkout!, configuration: Configuration): [Discount!]!
        }

        type Discount {
          subunits: Int
        }

        input Checkout {
          line_items: [LineItem!]!
        }

        input Configuration {
          value: Int
        }

        input LineItem {
          id: String!
          quantity: Int!
          title: String!
        }
        "
      end

      it "should generate the ts file for containing both input and configuration classes" do
        expected_output =
          <<~HEREDOC
            /*
             Do not change header,
             */
            import { Slice, Str, ID, Int, Float } from \"../shopify_runtime_types\";

            @unmanaged
            export class Discounts extends Slice<Discount> {
              static fromArray(arr: Array<Discount>): Discounts {
                return <Discounts>Slice.fromArray<Discount>(arr);
              }

              @inline
              static from(arr: Array<Discount>): Discounts {
                return Discounts.fromArray(arr);
              }
            }

            @unmanaged
            export class Discount {
              public subunits: Int;

              constructor(subunits: Int) {
                this.subunits = subunits;
              }
            }

            @unmanaged
            export class Checkout {
              public line_items: Slice<LineItem>;

              constructor(line_items: Array<LineItem>) {
                this.line_items = Slice.from<LineItem>(line_items);
              }
            }

            @unmanaged
            export class LineItem {
              public id: Str;
              public quantity: Int;
              public title: Str;

              constructor(id: String, quantity: Int, title: String) {
                this.id = Str.from(id);
                this.quantity = quantity;
                this.title = Str.from(title);
              }
            }

            @unmanaged
            export class Configuration {
              public value: Int;

              constructor(value: Int) {
                this.value = value;
              }
            }

          HEREDOC

        assert_equal expected_output, subject
      end
    end

    describe "when schema contains output that is not an array" do
      let(:schema) do
        "input Checkout {
          line_items: [LineItem!]!
        }

        input LineItem {
          titles: [String!]
        }

        type Discount {
          subunits: Int
        }

        type Query  {
          run(input: Checkout!): Discount!
        }
        "
      end

      it "should generate the ts file with correct classes " do
        expected_output =
          <<~HEREDOC
            /*
             Do not change header,
             */
            import { Slice, Str, ID, Int, Float } from \"../shopify_runtime_types\";


            @unmanaged
            export class Discount {
              public subunits: Int;

              constructor(subunits: Int) {
                this.subunits = subunits;
              }
            }

            @unmanaged
            export class Checkout {
              public line_items: Slice<LineItem>;

              constructor(line_items: Array<LineItem>) {
                this.line_items = Slice.from<LineItem>(line_items);
              }
            }

            @unmanaged
            export class LineItem {
              public titles: Slice<Str>;

              constructor(titles: Array<String>) {
                this.titles = Slice.from<Str>(titles.map(x => Str.from(x)));
              }
            }

          HEREDOC

        assert_equal expected_output, subject
      end
    end
  end
end
