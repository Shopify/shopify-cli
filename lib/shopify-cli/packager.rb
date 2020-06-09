module ShopifyCli
  class Packager
    def initialize
      @packaging_dir = File.join(ShopifyCli::ROOT, 'packaging')
      @builds_dir = File.join(@packaging_dir, 'builds', ShopifyCli::VERSION)
      FileUtils.mkdir_p(@builds_dir)
    end

    def build_debian
      ensure_brew_installed('dpkg')

      root_dir = File.join(@packaging_dir, 'debian')
      debian_dir = File.join(root_dir, 'shopify-cli', 'DEBIAN')
      FileUtils.mkdir_p(debian_dir)

      puts "Building Debian package"

      puts "Generating metadata files..."
      Dir.glob("#{debian_dir}/*").each { |file| File.delete(file) }

      metadata_files = %w(control postinst prerm)
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
      final_path = File.join(@builds_dir, "shopify-cli-#{ShopifyCli::VERSION}.deb")

      puts "Moving generated package: \n  From: #{output_path}\n  To: #{final_path}\n\n"
      FileUtils.mv(output_path, final_path)
    end

    def build_rpm
      ensure_brew_installed('rpm')

      root_dir = File.join(@packaging_dir, 'rpm')
      rpm_build_dir = File.join(root_dir, 'build')
      FileUtils.mkdir_p(rpm_build_dir)

      spec_path = File.join(root_dir, 'rubygem-shopify.spec')
      puts "Building RPM package"

      puts "Generating spec file..."
      File.delete(spec_path) if File.exist?(spec_path)

      spec_contents = File.read(File.join(root_dir, 'rubygem-shopify.spec.base'))
      spec_contents = spec_contents.gsub('SHOPIFY_CLI_VERSION', ShopifyCli::VERSION)
      File.write(spec_path, spec_contents)

      puts "Building package..."
      Dir.chdir(root_dir)
      system('rpmbuild', '-bb', File.basename(spec_path))

      output_dir = File.join(root_dir, 'build', 'noarch')

      puts "Moving generated packages: \n  From: #{output_dir}\n  To: #{@builds_dir}\n\n"
      FileUtils.mv(Dir.glob("#{output_dir}/*.rpm"), @builds_dir)
    end

    private

    def ensure_brew_installed(brew)
      unless ShopifyCli::Context.new.mac?
        raise "Package creation only works on Mac OS. Aborting operation"
      end

      brew_installed = system('brew', 'info', brew, out: File::NULL, err: File::NULL)
      unless brew_installed
        raise "Missing brew #{brew}, please install it. Aborting operation"
      end
    end
  end
end
