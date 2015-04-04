# This mixin is designed to suplement the UseCase mixin for cases where
# performing the UseCase might be split up over time. With some UseCases,
# whether for performance, data consistency, or other reasons, we need to do
# the bulk of the processing at one point, and save changes at another
# point. Complicating this is the idea that use-cases themselves may have
# several steps, a preparation step, commit (save) step, and an "after save"
# step. This mixin attempts to provide a simple framework for dealing with
# these concerns.
module SimpleUsecase
  module Preparable
    extend ActiveSupport::Concern
    
    # The primary difference is that use-cases using this mixin will define a
    # 'prepare' method, rather than a 'call' method. Prepare is responsible
    # for doing most of the work of the UseCase, including validating
    # input data, creating objects, retrieving remote resources, etc.
    def prepare
    end

    # We define the "call" method here to keep a consistent interface
    # with other UserCases. To have the same effect as it normally
    # does, 'call' needs to first process the UseCase, then commit it, then
    # run after_commit. In other words, as before, call does EVEYRTHING all
    # at once.
    def call(&block)
      prepare(&block)
      commit!
      after_commit
      return model
    end

    # We define a model accessor to fasicilitate accessing the primary model
    # (if any) this UseCase is associated with. Because the whole point of
    # preparable usecases is that we can prepare them (which will often case
    # mean creating and/or populating a model) but not commit (save) them right
    # away, it is important that the model be accessible later.
    attr_accessor :model

    # Commits this use-case, as well as any dependencies. To add custom commit
    # logic, you'll usually want to over-ride the commit_within_transaction! method.
    def commit!
      with_transaction do
        commit_within_transaction!
        usecase_dependencies.each(&:commit!)
      end
    end

    # This method _should_ be over-written by child classes to specify what to do
    # on commit. Frequently this will be to save the model. Note that it is
    # unwise to put long-running or otherwise fragile processes in this method
    # (such as API calls) as it _will_ frequently be run within a database
    # transaction. The longer and more complex the code here, the greater the
    # chance of deadlocks and other DB errors.
    def commit_within_transaction!
      if model.present? && model.respond_to?(:save!)
        model.save!
      end
    end

    # after_commit can be over-written to perform longer running tasks that
    # should only be perfomed if commit! is successful, but don't necessarily
    # need to happen inside the transaction. This is an ideal place for
    # triggering background jobs, sending emails, etc.
    def after_commit
      usecase_dependencies.select {|d| d.respond_to? :after_commit}.each(&:after_commit)
    end

    # Registers the given usecase as a dependency. Any class that responds to a
    # "commit!" method is supported as a dependency.
    def register_usecase_dependency(usecase)
      unless usecase.respond_to? :commit!
        raise InvalidUsecaseDependency.new "Usecase #{usecase.class.name} does not have a commit! method, and so can't be registered as a dependency of #{self.class.name}."
      end
      usecase_dependencies << usecase
    end

    private
   
    def usecase_dependencies
      @usecase_dependenies ||= []
    end

    # Handles running the commit! code within a transaction, with support for
    # multiple DB backends in the future. Currently only supports ActiveRecord,
    # and will fall back to no-transaction support without it!
    def with_transaction
      if Object.const_defined? :ActiveRecord
        ActiveRecord::Base.transaction do
          yield
        end
      else
        yield
      end
    end
  end
end
