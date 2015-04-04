class <%= class_name %>
  include SimpleUsecase::All

  def initialize(form, auth_context)
    super
    self.form = form
  end

  def prepare

  end
end
