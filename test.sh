for i in {1..1000}
do
    echo "Execution: $i"
    ruby -I test test/shopify-cli/theme/dev_server/integration_test.rb || break
done
