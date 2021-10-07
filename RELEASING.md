## Releasing Shopify CLI

1. Check the Semantic Versioning page for info on how to version the new release: http://semver.org
2. Make sure you're on the most recent `main`
   ```
   $ git checkout main
   $ git pull
   ```
3. Create a branch named `release_X_Y_Z` (replacing `X_Y_Z` with the intended release version)
   ```
   $ git checkout -b release_X_Y_Z
   ```
4. Update the version of Shopify CLI in `lib/shopify_cli/version.rb`
5. Update the version of Shopify CLI at the top of `Gemfile.lock` (failing to do so causes the CI build to fail)
6. Add an entry for the new release to `CHANGELOG.md`
7. Commit the changes with a commit message like "Packaging for release X.Y.Z"
   ```
   $ git commit -am "Packaging for release vX.Y.Z"
   ```
8. Push out the changes
   ```
   $ git push -u origin release_X_Y_Z
   ```

9. Open a PR for the branch, get necessary approvals from code owners and merge into main branch. Note that the PR title will be the release note in Shipit, so make sure it mentions the release
10. Deploy using Shipit
11. Update your `main` branch to the latest version
   ```
   $ git checkout main
   $ git pull
   ```
   
12. On local machine and _AFTER_ gem has been published to https://rubygems.org, run
   ```
   $ rake package
   ```
   This will generate the `.deb`, `.rpm` and brew formula files, which will be located in `packaging/builds/X.Y.Z/`.

13. Clone the `Shopify/homebrew-shopify` repository (if not already cloned), and then
    * create a branch named `release_X_Y_Z_of_shopify-cli`
    * update the brew formula in `shopify-cli.rb` with the generated formula in `packaging/builds/X.Y.Z/` in the `Shopify/shopify-cli` repo (from the `rake package` step above)
    * commit the change and create a PR on the [Shopify Homebrew repository](https://github.com/Shopify/homebrew-shopify)
    * when PR is approved, merge into main branch
  
14. Go to [releases](https://github.com/Shopify/shopify-cli/releases) page of `Shopify/shopify-cli` repo and create a new release:
    * use the tag created by Shipit (should be "vX.Y.Z")
    * release title = "Version X.Y.Z"
    * description should be the content of the section in the `CHANGELOG.md`
    * upload the `.deb` and `.rpm` files from `packaging/builds/X.Y.Z/` (generated in step 9)
    * if it's a pre-release version, select the "This is a pre-release" checkbox
    * and click "Publish release".
15. Go through all the PR [labeled with `includes-post-release-steps`](https://github.com/Shopify/shopify-cli/labels/includes-post-release-steps) and follow the post-release steps described in those PRs. Delete the labels afterward.