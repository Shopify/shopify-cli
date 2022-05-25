module ShopifyCLI
  class Heroku
    DOWNLOAD_URLS = {
      linux: "https://cli-assets.heroku.com/heroku-linux-x64.tar.gz",
      mac: "https://cli-assets.heroku.com/heroku-darwin-x64.tar.gz",
      windows: "https://cli-assets.heroku.com/heroku-x64.exe",
      mac_m1: "https://cli-assets.heroku.com/heroku-darwin-x64.tar.gz",
    }

    def initialize(ctx)
      @ctx = ctx
    end

    def app
      return nil unless (app = git_remote)
      app = app.split("/").last
      app = app.split(".").first
      app
    end

    def authenticate
      result = @ctx.system(heroku_command, "login")
      @ctx.abort(@ctx.message("core.heroku.error.authentication")) unless result.success?
    end

    def create_new_app
      output, status = @ctx.capture2e(heroku_command, "create")
      @ctx.abort(@ctx.message("core.heroku.error.creation")) unless status.success?
      @ctx.puts(output)
    end

    def deploy(branch_to_deploy)
      result = @ctx.system("git", "push", "-u", "heroku", "#{branch_to_deploy}:master")
      @ctx.abort(@ctx.message("core.heroku.error.deploy")) unless result.success?
    end

    def download
      return if installed?

      result = @ctx.system("curl", "-o", download_path, DOWNLOAD_URLS[@ctx.os], chdir: ShopifyCLI.cache_dir)
      @ctx.abort(@ctx.message("core.heroku.error.download")) unless result.success?
      @ctx.abort(@ctx.message("core.heroku.error.download")) unless File.exist?(download_path)
    end

    def install
      return if installed?

      result = if @ctx.windows?
        @ctx.system("\"#{download_path}\"")
      else
        @ctx.system("tar", "-xf", download_path, chdir: ShopifyCLI.cache_dir)
      end
      @ctx.abort(@ctx.message("core.heroku.error.install")) unless result.success?

      @ctx.rm(download_path)
    end

    def select_existing_app(app_name)
      result = @ctx.system(heroku_command, "git:remote", "-a", app_name)

      msg = @ctx.message("core.heroku.error.could_not_select_app", app_name)
      @ctx.abort(msg) unless result.success?
    end

    def whoami
      output, status = @ctx.capture2e(heroku_command, "whoami")
      return output.strip if status.success?
      nil
    end

    def get_config(config)
      output, status = @ctx.capture2e(heroku_command, "config:get", config.to_s)
      return output.strip if status.success?
      nil
    end

    def set_config(config, value)
      result = @ctx.system(heroku_command, "config:set", "#{config}=#{value}")

      msg = @ctx.message("core.heroku.error.set_config", config, value)
      @ctx.abort(msg) unless result.success?
    end

    def add_buildpacks(buildpacks)
      result = @ctx.system(heroku_command, "buildpacks:clear")
      msg = @ctx.message("core.heroku.error.add_buildpacks")
      @ctx.abort(msg) unless result.success?

      buildpacks.each do |buildpack|
        result = @ctx.system(heroku_command, "buildpacks:add", buildpack)
        msg = @ctx.message("core.heroku.error.add_buildpacks")
        @ctx.abort(msg) unless result.success?
      end
    end

    def heroku_command
      local_path = File.join(ShopifyCLI.cache_dir, "heroku", "bin", "heroku").to_s
      if File.exist?(local_path)
        local_path
      elsif @ctx.windows?
        begin
          # Check if Heroku exists in the Windows registry and run it from there
          require "win32/registry"

          windows_path = Win32::Registry::HKEY_CURRENT_USER.open('SOFTWARE\heroku') do |reg|
            reg[""] # This reads the 'Default' registry key
          end

          File.join(windows_path, "bin", "heroku").to_s
        rescue StandardError, LoadError
          "heroku"
        end
      else
        "heroku"
      end
    end

    private

    def download_filename
      URI.parse(DOWNLOAD_URLS[@ctx.os]).path.split("/").last
    end

    def download_path
      File.join(ShopifyCLI.cache_dir, download_filename)
    end

    def git_remote
      output, status = @ctx.capture2e("git", "remote", "get-url", "heroku")
      status.success? ? output : nil
    end

    def installed?
      _output, status = @ctx.capture2e(heroku_command, "--version")
      status.success?
    rescue
      false
    end
  end
end
