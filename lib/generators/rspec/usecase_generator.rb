module Rspec
  module Generators
    class UsecaseGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def copy_usecase_test
        template "usecase_spec.rb", File.join("spec", "use_cases", "#{file_path}_spec.rb")
      end
    end
  end
end
