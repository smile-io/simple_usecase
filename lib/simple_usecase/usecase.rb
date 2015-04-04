module SimpleUsecase
  module Usecase 
    extend ActiveSupport::Concern
    
    included do
      def self.call(*args, auth_context, &block)
        new(*args, auth_context).call(&block)
      end

      attr_accessor :form, :model, :auth_context
    end

    def initialize(*args, auth_context)
      self.auth_context = auth_context
    end
  end
end
