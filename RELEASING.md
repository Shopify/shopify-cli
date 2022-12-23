## Releasing Shopify CLI

This page contains instructions for CLI 2.0. If you are looking for instructions for CLI 3.0, please visit the [CLI 3.0 documentation](https://github.com/Shopify/cli/blob/main/docs/release.md).

### Automated process

We release the CLI with a series of Rake tasks run locally, interspersed with PR-based checkpoints. The steps are:

1. `export GITHUB_ACCESS_TOKEN=$(dev github print-auth | grep Password | awk '{print $NF}')`
2. `rake "release:prepare[2.x.x]"` (where 2.x.x is the version being released)
3. PR to shopify-cli will open in your browser. Sanity-check and merge.
4. Trigger [Shipit](https://shipit.shopify.io/shopify/shopify-cli/rubygems) on your version commit to release on RubyGems
5. `rake release:package`
6. Homebrew PR will open in your browser. Sanity-check and merge.
7. Release will also be opened in your browser, check that it includes debian and rpm files.
8. Go through all the [PRs labeled with includes-post-release-steps](https://github.com/Shopify/shopify-cli/issues?q=label%3Aincludes-post-release-steps+is%3Aclosed) and follow the post-release steps described in those PRs. Delete the labels afterward.

In case the automation goes wrong, try with the manual instructions.

### Manual process

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
10. Deploy to RubyGems using [Shipit](https://shipit.shopify.io/shopify/shopify-cli/rubygems)
11. Update your `main` branch to the latest version
   ```
   $ git checkout main
   $ git pull
   ```
   
12. On local machine and _AFTER_ gem has been published to https://rubygems.org/gems/shopify-cli, run
   ```
   $ rake package
   ```
   This will generate the `.deb`, `.rpm` and brew formula files, which will be located in `packaging/builds/X.Y.Z/`.

13. Clone the `Shopify/homebrew-shopify` repository (if not already cloned), and then
    * update your `master` branch to the latest version: `git checkout master && git pull`
    * create a new branch: `git checkout -b release_X_Y_Z_of_shopify-cli`
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
