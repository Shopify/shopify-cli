for i in {1..100}
do
  echo "Execution ${i}"
  ruby -I test test/shopify-cli/theme/dev_server/integration_test.rb --seed 54807
done

