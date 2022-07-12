for i in {1..1000}
do
    echo "Execution: $i"
    # --name test_uploads_files_on_modification
    ruby -I test test/shopify-cli/theme/theme_admin_api_throttler/bulk_test.rb  --seed 3660 || break
done
