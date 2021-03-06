# frozen_string_literal: true

# rubocop-rspec gem extension of RuboCop's ExpectOffense module.
#
# This mixin is the same as rubocop's ExpectOffense except the default
# filename ends with `_spec.rb`
module ExpectOffense
  include RuboCop::RSpec::ExpectOffense

  DEFAULT_FILENAME = 'example_spec.rb'

  def expect_offense(source, filename = DEFAULT_FILENAME, *args, **kwargs) # rubocop:disable Lint/UselessMethodDefinition
    super
  end

  def expect_no_offenses(source, filename = DEFAULT_FILENAME) # rubocop:disable Lint/UselessMethodDefinition
    super
  end
end
