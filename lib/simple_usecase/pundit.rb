begin
  require 'pundit'
rescue LoadError
  raise UnmetDependency.new "Cannot use the SimpleUsecase::Pundit module without also installing the Pundit gem."
end

module SimpleUsecase
  module Pundit
    extend ActiveSupport::Concern
    include ::Pundit 

    def policy(model = nil)
      model ||= self.model
      super(model)
    end

    def pundit_user
      self.auth_context
    end
  end
end
