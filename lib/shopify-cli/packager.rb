module ShopifyCli
  class Packager
    PACKAGING_DIR = File.join(ShopifyCli::ROOT, 'packaging')
    BUILDS_DIR = File.join(PACKAGING_DIR, 'builds', ShopifyCli::VERSION)

    def initialize
      FileUtils.mkdir_p(BUILDS_DIR)
    end

    def build_debian
      ensure_program_installed('dpkg-deb', 'brew install dpkg')

      root_dir = File.join(PACKAGING_DIR, 'debian')
      debian_dir = File.join(root_dir, 'shopify-cli', 'DEBIAN')
      FileUtils.mkdir_p(debian_dir)

      puts "\nBuilding Debian package"

      puts "Generating metadata files..."
      Dir.glob("#{debian_dir}/*").each { |file| File.delete(file) }

      metadata_files = %w(control preinst prerm)
      metadata_files.each do |file|
        file_path = File.join(debian_dir, file)

        file_contents = File.read(File.join(root_dir, "#{file}.base"))
        file_contents = file_contents.gsub('SHOPIFY_CLI_VERSION', ShopifyCli::VERSION)
        File.open(file_path, 'w', 0775) { |f| f.write(file_contents) }
      end

      puts "Building package..."
      Dir.chdir(root_dir)
      raise "Failed to build package" unless system('dpkg-deb', '-b', 'shopify-cli')

      output_path = File.join(root_dir, 'shopify-cli.deb')
      final_path = File.join(BUILDS_DIR, "shopify-cli-#{ShopifyCli::VERSION}.deb")

      puts "Moving generated package: \n  From: #{output_path}\n  To: #{final_path}\n\n"
      FileUtils.mv(output_path, final_path)
    end

    def build_rpm
      ensure_program_installed('rpmbuild', 'brew install rpm')

      root_dir = File.join(PACKAGING_DIR, 'rpm')
      rpm_build_dir = File.join(root_dir, 'build')
      FileUtils.mkdir_p(rpm_build_dir)

      spec_path = File.join(root_dir, 'shopify-cli.spec')
      puts "\nBuilding RPM package"

      puts "Generating spec file..."
      File.delete(spec_path) if File.exist?(spec_path)

      spec_contents = File.read(File.join(root_dir, 'shopify-cli.spec.base'))
      spec_contents = spec_contents.gsub('SHOPIFY_CLI_VERSION', ShopifyCli::VERSION)
      File.write(spec_path, spec_contents)

      puts "Building package..."
      Dir.chdir(root_dir)
      system('rpmbuild', '-bb', File.basename(spec_path))

      output_dir = File.join(root_dir, 'build', 'noarch')

      puts "Moving generated packages: \n  From: #{output_dir}\n  To: #{BUILDS_DIR}\n\n"
      FileUtils.mv(Dir.glob("#{output_dir}/*.rpm"), BUILDS_DIR)
    end

    def build_homebrew
      root_dir = File.join(PACKAGING_DIR, 'homebrew')

      build_path = File.join(BUILDS_DIR, "shopify-cli.rb")
      puts "\nBuilding Homebrew package"

      puts "Generating formula..."
      File.delete(build_path) if File.exist?(build_path)

      spec_contents = File.read(File.join(root_dir, 'shopify-cli.base.rb'))
      spec_contents = spec_contents.gsub('SHOPIFY_CLI_VERSION', ShopifyCli::VERSION)

      puts "Grabbing sha256 checksum from Rubygems.org"
      require 'digest/sha2'
      require 'open-uri'
      gem_checksum = open("https://rubygems.org/downloads/shopify-cli-#{ShopifyCli::VERSION}.gem") do |io|
        Digest::SHA256.new.hexdigest(io.read)
      end

      puts "Got sha256 checksum for gem: #{gem_checksum}"
      spec_contents = spec_contents.gsub('SHOPIFY_CLI_GEM_CHECKSUM', gem_checksum)

      puts "Writing generated formula\n  To: #{build_path}\n\n"
      File.write(build_path, spec_contents)
    end

    def build_choco
      ensure_program_installed('mono', 'brew install mono')

      root_dir = File.join(PACKAGING_DIR, 'chocolatey')
      choco_path = File.join('choco-static', 'choco.exe')

      choco_build_dir = File.join(root_dir, 'build')
      FileUtils.rm_r(choco_build_dir) if Dir.exist?(choco_build_dir)
      FileUtils.mkdir(choco_build_dir)

      choco_tools_dir = File.join(choco_build_dir, 'tools')
      FileUtils.mkdir(choco_tools_dir)

      puts "\nBuilding Chocolatey package"

      puts "Generating metadata files..."

      spec_file = 'shopify-cli.nuspec'

      file_contents = File.read(File.join(root_dir, "#{spec_file}.base"))
      file_contents = file_contents.gsub('SHOPIFY_CLI_VERSION', ShopifyCli::VERSION)
      File.write(File.join(choco_build_dir, spec_file), file_contents)

      tools_files = %w(chocolateyInstall.ps1 chocolateyUninstall.ps1)
      tools_files.each do |file|
        file_path = File.join(choco_build_dir, 'tools', file)

        file_contents = File.read(File.join(root_dir, "#{file}.base"))
        file_contents = file_contents.gsub('SHOPIFY_CLI_VERSION', ShopifyCli::VERSION)
        File.write(file_path, file_contents)
      end

      puts "Building package..."
      Dir.chdir(choco_build_dir)
      raise "Failed to build package" unless system('mono', "../#{choco_path}", 'pack', '--allow-unofficial', spec_file)

      output_file = "shopify-cli.#{ShopifyCli::VERSION}.nupkg"
      output_path = File.join(choco_build_dir, output_file)
      final_path = File.join(BUILDS_DIR, output_file)

      puts "Moving generated package: \n  From: #{output_path}\n  To: #{final_path}\n\n"
      FileUtils.mv(output_path, final_path)
    end

    private

    def ensure_program_installed(program, installation_cmd)
      unless system(program, '--version', out: File::NULL, err: File::NULL)
        raise <<~MESSAGE

          Could not find program #{program} which is required to build the package.
          You can install it by running `#{installation_cmd}`.

        MESSAGE
      end
    end
  end
end
