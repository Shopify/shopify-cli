require "rdoc/rdoc"
require "erb"

module RDoc
  module Generator
    class Markdown
      ::RDoc::RDoc.add_generator(self)

      DocClass = Struct.new(
        :title, :kind, :comment, :class_methods, :instance_methods, :attributes,
        :constants, :extended, :included, :filename,
        keyword_init: true,
      )
      ClassMember = Struct.new(:title, :comment, :signature, :source_code, keyword_init: true)

      def initialize(store, options)
        @options = options
        @store = store
        @converter = ::RDoc::Markup::ToMarkdown.new
      end

      def generate
        render(build_classes)
      end

      private

      def render(data)
        class_template_path = File.join(File.dirname(__FILE__), "class_template.md.erb")
        class_renderer = ERB.new(File.read(class_template_path), nil, "-")
        data.each do |cls|
          File.write("#{cls.filename}.md", class_renderer.result(cls.instance_eval { binding }))
        end
        index_template_path = File.join(File.dirname(__FILE__), "index_template.md.erb")
        index_renderer = ERB.new(File.read(index_template_path), nil, "-")
        File.write("Core-APIs.md", index_renderer.result(OpenStruct.new(classes: data).instance_eval { binding }))
      end

      def build_classes
        classes = @store.all_classes_and_modules.map do |klass|
          is_class = @store.all_modules.find { |m| m.full_name == klass.full_name }.nil?
          kind = is_class ? :class : :module
          DocClass.new(
            filename: "#{kind}-#{klass.full_name}",
            title: klass.full_name,
            kind: kind,
            comment: @converter.convert(klass.comment.parse),
            constants: build_members(klass.constants),
            class_methods: build_members(klass.method_list.select { |m| m.type == "class" }),
            instance_methods: build_members(klass.method_list.select { |m| m.type == "instance" }),
            attributes: build_members(klass.attributes),
            extended: build_members(klass.extends),
            included: build_members(klass.includes),
          )
        end

        # Remove nondescript items
        classes.reject do |klass|
          klass.comment.empty? && klass.constants.empty? &&
            klass.class_methods.empty? && klass.instance_methods.empty? &&
            klass.attributes.empty? && klass.extended.empty? &&
            klass.included.empty?
        end
      end

      def build_members(member_list)
        member_list.map do |m|
          ClassMember.new(
            title:     m.name,
            comment:   @converter.convert(m.comment.parse),
            signature: m.respond_to?(:arglists) ? m.arglists : "",
            source_code: source(m),
          )
        end
      end

      # Just extracts sourcecode from html formatting/highlighting into a text
      # blob so that markdown can format it with a codeblock
      def source(m)
        return "" unless m.respond_to?(:token_stream)
        # each line, get the text
        src = (m.token_stream || []).map do |t|
          next unless t
          CGI.escapeHTML(t[:text])
        end.join
        # dedent the source
        indent = src.length
        lines = src.lines.to_a
        lines.shift if src =~ /\A.*#\ *File/i # remove '# File' comment
        lines.each do |line|
          next unless line =~ /^ *(?=\S)/
          n = Regexp.last_match(0).length
          indent = n if n < indent
          break if n == 0
        end
        src.gsub!(/^#{' ' * indent}/, "") if indent > 0
        src
      end
    end
  end
end
