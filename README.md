# Simple Usecase

Simple Usecase provides a simple yet effective interface for writing
composable, "UseCase" classes that make up an application's domain logic.

*Note on Terms:* Throughout this document, the convention of using periods and hash
symbols to designate class and instance level methods, respectively, will be
used. E.g. `#call` is an instance level method named "call". `.call` is a
class level method.
method 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_usecase'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_usecase

## Usage

### Core Inteface

To use the SimpleUsecase basic interface, include it into your Usecase class,
like so:

```ruby
include SimpleUsecase::Core
```

Simple Usecase's core interface is of a class which takes at least one
parameter on instantiation, known as an "authentication_context". This object
should represent the object that is authenticated for the activity to be
performed by the Usecase. In most situations this will simply be your `User`
object, (if using Rails with Devise, it might well be the result of calling
`current_user` in your controller). Usecases _may_ take aditional paramers, in
which case the authentication_context is always considered the _last_
parameter.

Within a Usecase instance, a public accesser `#auth_context` gives access to the
authenticated context.

Once instantiated, a Usecase object performs it's operations within a `#call`
method.

To fascilitate the creation of a Usecase object and calling it in one step, a
class-level `.call` method is made available (e.g. `MyUsecase.call`). This
method's parameters will be used to instantiate an instance of the class, and
then the instance level `#call` method will be immediately called. Any block
passed to `.call` will be passed to `#call`.

The instance level `#call` method is defined as empty, and it is expected that
you will customize this method with the specific logic your Usecase is
concerned with.

As an example, a contrived Usecase to add two values:
```ruby
class AddValues
  include SimpleUsecase::Core

  def initialize(var_a, var_b)
    @var_a, @var_b = var_a, var_b
  end

  def call
    var_a + var_b
  end
end
```

This can be called first by instantiating the class, and then calling #call:
```ruby
adder = AddValues.new(5, 3)
adder.call # returns 8
```

Or, the shortcut can be used to instantiate and call the instance at once:
```ruby
AddValues.call(5, 3) # returns 8
```

### The Preparable Interface

In adition to the core interface, Simple Usecase offers an expansion of that
interface that is focused on separating the #call method into more detailed
steps. Those steps are

1. *Prepare:* Any operations that can be done in memory, or that involve
   fetching aditional data, but where concerns about transactionality are not a
   cncern, should be done in the prepare step.
2. *Commit!* The commit step is where the core action of the Usecase is
   designed to take place, e.g. saving records to the database. Dependent
   Usecases will have their commit steps run within a database transaction, if
   supported.
3. *After Commit* Supporting or clean-up steps that should happen after the 
   commit step has been successfully completed. As an example, queuing further
   processing of records that were created in the commit! step.

To use the Preparable interface, include it into your class in addition to the 
core interface, like this:

```ruby
include SimpleUsecase::Core
include SimpleUsecase::Preparable
```

Alternatively, you may instead include the `All` module, which includes 
`Core`, `Preparable`, and possibly other modules as they are added:

```ruby
include SimpleUsecase::All
```

To get the best use out of the Preparable interface, perform as much of your
logic as you can in the `#prepare` method. By default, the Preparable interface
makes avaialbe a `#model` accessor, and will, by default try to call `#save!` on 
any object stored in it when the commit step is reached. To over-ride this
behavior, define a method `#commit_within_transaction!` with
your own commit logic. Also consider redefining the `after_commit` method to
add logic that should only run _after_ the commit step is complete.

For more details, please read the [Preparable
code](./lib/simple_usecase/preparable.rb) itself, as it is heavily
commented and quite straight forward.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/simple_usecase/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
