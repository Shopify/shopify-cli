module ShopifyCli
  class Packager
    PACKAGING_DIR = File.join(ShopifyCli::ROOT, 'packaging')
    BUILDS_DIR = File.join(PACKAGING_DIR, 'builds', ShopifyCli::VERSION)

    def initialize
      FileUtils.mkdir_p(BUILDS_DIR)
    end

    def build_gem
      build_path = gem_path
      puts "\nBuilding gem"

      puts "Outputting gem to:\n  #{build_path}\n\n"
      raise "Failed to build gem" unless system(
        'gem',
        'build',
        '-o',
        build_path,
        File.join(ShopifyCli::ROOT, 'shopify-cli.gemspec')
      )
    end

    def build_debian
      ensure_program_installed('dpkg-deb')

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
      ensure_program_installed('rpmbuild')

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

      checksum = %x`shasum -a 256 #{gem_path}`
      gem_checksum = checksum.split(' ')[0]

      puts "Got sha256 sum for gem: #{gem_checksum}"
      spec_contents = spec_contents.gsub('SHOPIFY_CLI_GEM_CHECKSUM', gem_checksum)

      puts "Writing generated formula\n  To: #{build_path}\n\n"
      File.write(build_path, spec_contents)
    end

    private

    def ensure_program_installed(program)
      raise "Could not find program #{program} which is required to build the package" unless
        system(program, '--version', out: File::NULL, err: File::NULL)
    end

    def gem_path
      File.join(BUILDS_DIR, "shopify-cli.gem")
    end
  end
end
