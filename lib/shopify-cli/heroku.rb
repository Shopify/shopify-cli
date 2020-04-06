module ShopifyCli
  class Heroku
    DOWNLOAD_URLS = {
      linux: 'https://cli-assets.heroku.com/heroku-linux-x64.tar.gz',
      mac: 'https://cli-assets.heroku.com/heroku-darwin-x64.tar.gz',
      windows: 'https://cli-assets.heroku.com/heroku-win32-x64.tar.gz',
    }

    def initialize(ctx)
      @ctx = ctx
    end

    def app
      return nil unless (app = git_remote)
      app = app.split('/').last
      app = app.split('.').first
      app
    end

    def authenticate
      result = @ctx.system(heroku_command, 'login')
      @ctx.abort("Could not authenticate with Heroku") unless result.success?
    end

    def create_new_app
      output, status = @ctx.capture2e(heroku_command, 'create')
      @ctx.abort('Heroku app could not be created') unless status.success?
      @ctx.puts(output)

      new_remote = output.split("\n").last.split("|").last.strip
      result = @ctx.system('git', 'remote', 'add', 'heroku', new_remote)

      msg = "Heroku app created, but couldn’t be set as a git remote"
      @ctx.abort(msg) unless result.success?
    end

    def deploy(branch_to_deploy)
      result = @ctx.system('git', 'push', '-u', 'heroku', "#{branch_to_deploy}:master")
      @ctx.abort("Could not deploy to Heroku") unless result.success?
    end

    def download
      return if installed?

      result = @ctx.system('curl', '-o', download_path, DOWNLOAD_URLS[@ctx.os], chdir: ShopifyCli::ROOT)
      @ctx.abort("Heroku CLI could not be downloaded") unless result.success?
      @ctx.abort("Heroku CLI could not be downloaded") unless File.exist?(download_path)
    end

    def install
      return if installed?

      result = @ctx.system('tar', '-xf', download_path, chdir: ShopifyCli::ROOT)
      @ctx.abort("Could not install Heroku CLI") unless result.success?

      @ctx.rm(download_path)
    end

    def select_existing_app(app_name)
      result = @ctx.system(heroku_command, 'git:remote', '-a', app_name)

      msg = "Heroku app `#{app_name}` could not be selected"
      @ctx.abort(msg) unless result.success?
    end

    def whoami
      output, status = @ctx.capture2e(heroku_command, 'whoami')
      return output.strip if status.success?
      nil
    end

    private

    def download_filename
      URI.parse(DOWNLOAD_URLS[@ctx.os]).path.split('/').last
    end

    def download_path
      File.join(ShopifyCli::ROOT, download_filename)
    end

    def git_remote
      output, status = @ctx.capture2e('git', 'remote', 'get-url', 'heroku')
      status.success? ? output : nil
    end

    def heroku_command
      local_path = File.join(ShopifyCli::ROOT, 'heroku', 'bin', 'heroku').to_s
      if File.exist?(local_path)
        local_path
      else
        'heroku'
      end
    end

    def installed?
      _output, status = @ctx.capture2e(heroku_command, '--version')
      status.success?
    rescue
      false
    end
  end
end
