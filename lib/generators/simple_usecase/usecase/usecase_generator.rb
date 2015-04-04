module SimpleUsecase
  module Generators
    class UsecaseGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      def copy_usecase_file
        template "usecase.rb", File.join("app", "use_cases", "#{file_path}.rb")
      end

      hook_for :test_framework
    end
  end
end
