# typed: ignore
module TestHelpers
  module Heroku
    protected

    def stub_successful_heroku_flow(full_path: false)
      # installed
      File.stubs(:exist?)
        .with(heroku_command(full_path: full_path))
        .returns(true)

      @context.stubs(:capture2e)
        .with(heroku_command(full_path: full_path), "--version")
        .returns(["", status_mock[:true]])

      # init
      init_output = <<~EOS
        On branch master
        Your branch is up to date with 'heroku/master'.

        nothing to commit, working tree clean
      EOS

      @context.stubs(:capture2e)
        .with("git", "status")
        .returns([init_output, status_mock[:true]])

      # db validation
      @context.stubs(:capture2e)
        .with('bundle exec rails runner "puts ActiveRecord::Base.connection.adapter_name.downcase"')
        .returns(["mysql", status_mock[:true]])

      # whoami
      @context.stubs(:capture2e)
        .with(heroku_command(full_path: full_path), "whoami")
        .returns(["username", status_mock[:true]])

      # heroku.app
      @context.stubs(:capture2e)
        .with("git", "remote", "get-url", "heroku")
        .returns([heroku_remote, status_mock[:true]])

      # git branches
      @context.stubs(:capture2e)
        .with("git", "branch", "--list", "--format=%(refname:short)")
        .returns(["master\n", status_mock[:true]])

      # heroku.get_config
      @context.stubs(:capture2e)
        .with do |heroku_cmd, config_cmd, _config|
          heroku_cmd == heroku_command(full_path: full_path) && config_cmd == "config:get"
        end
        .returns(["", status_mock[:true]])

      # heroku.set_config
      @context.stubs(:system)
        .with do |heroku_cmd, config_cmd, _config, _value|
          heroku_cmd == heroku_command(full_path: full_path) && config_cmd == "config:set"
        end
        .returns(status_mock[:true])

      # create new php app key
      @context.stubs(:capture2e)
        .with("php", "artisan", "key:generate", "--show")
        .returns(["new_key", status_mock[:true]])

      # heroku.add_buildpacks
      @context.stubs(:system)
        .with(heroku_command(full_path: full_path), "buildpacks:clear")
        .returns(status_mock[:true])

      @context.stubs(:system)
        .with do |heroku_cmd, pack_cmd, _pack|
          heroku_cmd == heroku_command(full_path: full_path) && pack_cmd == "buildpacks:add"
        end
        .returns(status_mock[:true])

      # deploy
      @context.stubs(:system)
        .with("git", "push", "-u", "heroku", "master:master")
        .returns(status_mock[:true])

      # user outputs
      @context.stubs(:puts)
    end

    def expects_tar_heroku(status:)
      if status.nil?
        @context.expects(:system)
          .with("tar", "-xf", download_path, chdir: ShopifyCLI.cache_dir)
          .never
      else
        @context.expects(:system)
          .with("tar", "-xf", download_path, chdir: ShopifyCLI.cache_dir)
          .returns(status_mock[:"#{status}"])
      end

      if status
        @context.expects(:rm).with(download_path).returns(status)
      else
        @context.expects(:rm).with(download_path).never
      end
    end

    def expects_git_branch(status: true, multiple:)
      output = "master\n"
      output << "other_branch\n" if multiple

      @context.expects(:capture2e)
        .with("git", "branch", "--list", "--format=%(refname:short)")
        .returns([output, status_mock[:"#{status}"]])
    end

    def expects_git_init_heroku(status:, commits:)
      output = if commits == true
        <<~EOS
          On branch master
          Your branch is up to date with 'heroku/master'.

          nothing to commit, working tree clean
        EOS
      else
        <<~EOS
          On branch master

          No commits yet
        EOS
      end

      @context.expects(:capture2e)
        .with("git", "status")
        .returns([output, status_mock[:"#{status}"]])
    end

    def expects_git_remote_get_url_heroku(status:, remote:)
      output = if status == true
        heroku_remote
      else
        "fatal: No such remote '#{remote}'"
      end

      @context.expects(:capture2e)
        .with("git", "remote", "get-url", remote)
        .returns([output, status_mock[:"#{status}"]])
    end

    def expects_git_push_heroku(status:, branch:)
      @context.expects(:system)
        .with("git", "push", "-u", "heroku", branch)
        .returns(status_mock[:"#{status}"])
    end

    def expects_heroku_create(status:, full_path: false)
      output = <<~EOS
        Creating app... done, ⬢ app-name
        https://app-name.herokuapp.com/ | #{heroku_remote}
      EOS

      @context.expects(:capture2e)
        .with(heroku_command(full_path: full_path), "create")
        .returns([output, status_mock[:"#{status}"]])
    end

    def expects_heroku_login(status:, full_path: false)
      @context.expects(:system)
        .with(heroku_command(full_path: full_path), "login")
        .returns(status_mock[:"#{status}"])
    end

    def expects_heroku_deploy(status:)
      @context.expects(:system)
        .with("git", "push", "-u", "heroku", "master:master")
        .returns(status_mock[:"#{status}"])
    end

    def expects_heroku_db_validated(status:, db:)
      @context.expects(:capture2e)
        .with('bundle exec rails runner "puts ActiveRecord::Base.connection.adapter_name.downcase"')
        .returns([db, status_mock[:"#{status}"]])
    end

    def expects_heroku_download_exists(status:)
      File.expects(:exist?)
        .with(download_path)
        .returns(status)
    end

    def expects_heroku_download(status:)
      if status.nil?
        @context.expects(:system)
          .with("curl", "-o", download_path,
            ShopifyCLI::Heroku::DOWNLOAD_URLS[:mac],
            chdir: ShopifyCLI.cache_dir)
          .never
      else
        @context.expects(:system)
          .with("curl", "-o", download_path,
            ShopifyCLI::Heroku::DOWNLOAD_URLS[:mac],
            chdir: ShopifyCLI.cache_dir)
          .returns(status_mock[:"#{status}"])
      end
    end

    def expects_heroku_get_config(status:, config: nil, value: nil, full_path: false)
      if status
        @context.expects(:capture2e)
          .with(heroku_command(full_path: full_path), "config:get", config)
          .returns([value, status_mock[:true]])
      else
        @context.expects(:capture2e)
          .with do |called_cmd, called_heroku_cmd, called_config|
            called_cmd == heroku_command(full_path: full_path) &&
            called_heroku_cmd == "config:get" &&
            (!called_config || config == called_config)
          end
          .returns(["", status_mock[:false]])
      end
    end

    def expects_heroku_installed(status:, full_path: false, twice: false)
      File.stubs(:exist?)
        .with(heroku_command(full_path: full_path))
        .returns(status)

      if twice
        @context.expects(:capture2e)
          .with(heroku_command(full_path: full_path), "--version")
          .returns(["", status_mock[:"#{status}"]]).twice
      else
        @context.expects(:capture2e)
          .with(heroku_command(full_path: full_path), "--version")
          .returns(["", status_mock[:"#{status}"]])
      end
    end

    def expects_heroku_select_app(status:, full_path: false)
      @context.expects(:system)
        .with(heroku_command(full_path: full_path), "git:remote", "-a", "app-name")
        .returns(status_mock[:"#{status}"])
    end

    def expects_heroku_add_buildpacks(clear_status:, add_status:, buildpacks: nil, full_path: false)
      @context.expects(:system)
        .with(heroku_command(full_path: full_path), "buildpacks:clear")
        .returns(status_mock[:"#{clear_status}"])

      if clear_status
        buildpacks.each do |buildpack|
          @context.expects(:system)
            .with(heroku_command(full_path: full_path), "buildpacks:add", buildpack)
            .returns(status_mock[:"#{add_status}"])

          break unless add_status
        end
      end
    end

    def expects_heroku_set_config(status:, config: nil, value: nil, full_path: false)
      if status
        @context.expects(:system)
          .with(heroku_command(full_path: full_path), "config:set", "#{config}=#{value}")
          .returns(status_mock[:true])
      else
        @context.expects(:system)
          .with do |called_cmd, called_heroku_cmd, called_config, called_value|
            called_cmd == heroku_command(full_path: full_path) &&
            called_heroku_cmd == "config:set" &&
            (!called_value || value == called_value)
            (!called_config || config == called_config)
          end
          .returns(status_mock[:false])
      end
    end

    def expects_heroku_whoami(status:, full_path: false)
      output = status ? "username" : nil

      @context.expects(:capture2e)
        .with(heroku_command(full_path: full_path), "whoami")
        .returns([output, status_mock[:"#{status}"]])
    end

    def expects_php_key_generate(status:)
      output = status ? "new_key" : nil

      @context.expects(:capture2e)
        .with("php", "artisan", "key:generate", "--show")
        .returns([output, status_mock[:"#{status}"]])
    end

    private

    def download_filename
      "heroku-darwin-x64.tar.gz"
    end

    def download_path
      File.join(ShopifyCLI.cache_dir, download_filename)
    end

    def heroku_command(full_path: false)
      if full_path
        File.stubs(:exist?).returns(true)
        File.join(ShopifyCLI.cache_dir, "heroku", "bin", "heroku").to_s
      else
        "heroku"
      end
    end

    def heroku_remote
      "https://git.heroku.com/app-name.git"
    end

    def status_mock
      status_mock = {
        false: mock,
        true: mock,
      }
      status_mock[:false].stubs(:success?).returns(false)
      status_mock[:true].stubs(:success?).returns(true)
      status_mock
    end
  end
end
