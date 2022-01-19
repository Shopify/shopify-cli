require 'test/unit'
LOADING_RUBY2_KEYWORDS = (RUBY_VERSION.scan(/\d+/).map(&:to_i) <=> [2, 7]) < 0
if LOADING_RUBY2_KEYWORDS
  require 'ruby2_keywords'
end

class TestKeywordArguments < Test::Unit::TestCase
  def test_loaded_features
    list = $LOADED_FEATURES.grep(%r[/ruby2_keywords\.rb\z])
    if LOADING_RUBY2_KEYWORDS
      assert_not_empty(list)
      assert_not_include($LOADED_FEATURES, "ruby2_keywords.rb")
    else
      assert_empty(list)
      assert_include($LOADED_FEATURES, "ruby2_keywords.rb")
    end
  end

  def test_module_ruby2_keywords
    assert_send([Module, :private_method_defined?, :ruby2_keywords])
    assert_operator(Module.instance_method(:ruby2_keywords).arity, :<, 0)
  end

  def test_toplevel_ruby2_keywords
    main = TOPLEVEL_BINDING.receiver
    assert_send([main, :respond_to?, :ruby2_keywords, true])
    assert_operator(main.method(:ruby2_keywords).arity, :<, 0)
  end

  def test_proc_ruby2_keywords
    assert_respond_to(Proc.new {}, :ruby2_keywords)
  end

  def test_hash_ruby2_keywords_hash?
    assert_false(Hash.ruby2_keywords_hash?({}))
  end

  def test_hash_ruby2_keywords_hash
    assert_equal({}, Hash.ruby2_keywords_hash({}.freeze))
  end
end
