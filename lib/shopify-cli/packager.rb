module ShopifyCli
  class Packager
    PACKAGING_DIR = File.join(ShopifyCli::ROOT, 'packaging')
    BUILDS_DIR = File.join(PACKAGING_DIR, 'builds', ShopifyCli::VERSION)

    def initialize
      FileUtils.mkdir_p(BUILDS_DIR)
    end

    def build_debian
      ensure_program_installed('dpkg-deb')

      root_dir = File.join(PACKAGING_DIR, 'debian')
      debian_dir = File.join(root_dir, 'shopify-cli', 'DEBIAN')
      FileUtils.mkdir_p(debian_dir)

      puts "\nBuilding Debian package"

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
      final_path = File.join(BUILDS_DIR, "shopify-cli-#{ShopifyCli::VERSION}.deb")

      puts "Moving generated package: \n  From: #{output_path}\n  To: #{final_path}\n\n"
      FileUtils.mv(output_path, final_path)
    end

    def build_rpm
      ensure_program_installed('rpmbuild')

      root_dir = File.join(PACKAGING_DIR, 'rpm')
      rpm_build_dir = File.join(root_dir, 'build')
      FileUtils.mkdir_p(rpm_build_dir)

      spec_path = File.join(root_dir, 'rubygem-shopify.spec')
      puts "\nBuilding RPM package"

      puts "Generating spec file..."
      File.delete(spec_path) if File.exist?(spec_path)

      spec_contents = File.read(File.join(root_dir, 'rubygem-shopify.spec.base'))
      spec_contents = spec_contents.gsub('SHOPIFY_CLI_VERSION', ShopifyCli::VERSION)
      File.write(spec_path, spec_contents)

      puts "Building package..."
      Dir.chdir(root_dir)
      system('rpmbuild', '-bb', File.basename(spec_path))

      output_dir = File.join(root_dir, 'build', 'noarch')

      puts "Moving generated packages: \n  From: #{output_dir}\n  To: #{BUILDS_DIR}\n\n"
      FileUtils.mv(Dir.glob("#{output_dir}/*.rpm"), BUILDS_DIR)
    end

    private

    def ensure_program_installed(program)
      raise "Could not find program #{program} which is required to build the package" unless
        system(program, '--version', out: File::NULL, err: File::NULL)
    end
  end
end
