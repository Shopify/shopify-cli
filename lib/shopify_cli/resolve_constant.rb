##
# `ResolveConstant` implements constant resolution. It is implemented as a
# `MethodObject` and therefore returns a result object. By default, constants
# are resolved relative to `Kernal`, but the top-level namespace is
# configurable:
#
#    ShopifyCli::Resolve.call(:object).value # => Object
#    ShopifyCli::Resolve.call('minitest/test').value # => MiniTest::Test
#    ShopifyCli::Resolve.call(:test, namespace: MiniTest) # => MiniTest::Test
#
module ShopifyCli
  class ResolveConstant
    include ShopifyCli::MethodObject
    property! :namespace, accepts: ->(ns) { ns.respond_to?(:const_get) }, default: -> { Kernel }

    def call(name)
      name
        .to_s
        .split(%r{/|:{2}})
        .map { |const_name| const_name.split(/[_-]/).map(&:capitalize).join("") }
        .join("::")
        .yield_self { |const_name| namespace.const_get(const_name) }
    end
  end
end
