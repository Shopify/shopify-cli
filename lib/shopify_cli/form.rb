require "shopify_cli"

module ShopifyCLI
  class Form
    class << self
      def ask(ctx, args, flags)
        attrs = {}
        (@positional_arguments || []).each { |name| attrs[name] = args.shift }
        return nil if attrs.any? { |_k, v| v.nil? }
        (@flag_arguments || []).each { |arg| attrs[arg] = flags[arg] }
        form = new(ctx, args, attrs)
        begin
          form.ask
          form
        rescue ShopifyCLI::Abort => err
          ctx.puts(err.message)
          nil
        rescue ShopifyCLI::AbortSilent
          nil
        end
      end

      def positional_arguments(*args)
        @positional_arguments = args
        attr_accessor(*args)
      end

      def flag_arguments(*args)
        @flag_arguments = args
        attr_accessor(*args)
      end
    end

    attr_accessor :ctx, :xargs

    def initialize(ctx, xargs, attributes)
      @ctx = ctx
      @xargs = xargs
      attributes.each { |k, v| send("#{k}=", v) unless v.nil? }
    end
  end
end
