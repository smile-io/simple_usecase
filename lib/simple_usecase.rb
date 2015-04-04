require "active_support/concern"

require "simple_usecase/version"
require "simple_usecase/usecase"
require "simple_usecase/preparable"
require "simple_usecase/pundit"

require "simple_usecase/errors/invalid_usecase_dependency"

module SimpleUsecase
  module All
    extend ActiveSupport::Concern
    include SimpleUsecase::Usecase
    include SimpleUsecase::Preparable

    begin
      require 'pundit'
      include SimpleUsecase::Pundit
    rescue LoadError
      # No-op
    end
  end

  module Core
    extend ActiveSupport::Concern
    include SimpleUsecase::Usecase
  end
end
