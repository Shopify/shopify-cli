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
      @ctx.abort(@ctx.message('core.heroku.error.authentication')) unless result.success?
    end

    def create_new_app
      output, status = @ctx.capture2e(heroku_command, 'create')
      @ctx.abort(@ctx.message('core.heroku.error.creation')) unless status.success?
      @ctx.puts(output)
    end

    def deploy(branch_to_deploy)
      result = @ctx.system('git', 'push', '-u', 'heroku', "#{branch_to_deploy}:master")
      @ctx.abort(@ctx.message('core.heroku.error.deploy')) unless result.success?
    end

    def download
      return if installed?

      result = @ctx.system('curl', '-o', download_path, DOWNLOAD_URLS[@ctx.os], chdir: ShopifyCli::CACHE_DIR)
      @ctx.abort(@ctx.message('core.heroku.error.download')) unless result.success?
      @ctx.abort(@ctx.message('core.heroku.error.download')) unless File.exist?(download_path)
    end

    def install
      return if installed?

      result = @ctx.system('tar', '-xf', download_path, chdir: ShopifyCli::CACHE_DIR)
      @ctx.abort(@ctx.message('core.heroku.error.install')) unless result.success?

      @ctx.rm(download_path)
    end

    def select_existing_app(app_name)
      result = @ctx.system(heroku_command, 'git:remote', '-a', app_name)

      msg = @ctx.message('core.heroku.error.could_not_select_app', app_name)
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
      File.join(ShopifyCli::CACHE_DIR, download_filename)
    end

    def git_remote
      output, status = @ctx.capture2e('git', 'remote', 'get-url', 'heroku')
      status.success? ? output : nil
    end

    def heroku_command
      local_path = File.join(ShopifyCli::CACHE_DIR, 'heroku', 'bin', 'heroku').to_s
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
