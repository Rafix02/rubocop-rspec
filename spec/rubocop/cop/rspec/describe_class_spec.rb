# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::DescribeClass, :config do
  it 'checks first-line describe statements' do
    expect_offense(<<-RUBY)
      describe "bad describe" do
               ^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
    RUBY
  end

  it 'supports RSpec.describe' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe Foo do
      end
    RUBY
  end

  it 'supports ::RSpec.describe' do
    expect_no_offenses(<<-RUBY)
      ::RSpec.describe Foo do
      end
    RUBY
  end

  it 'checks describe statements after a require' do
    expect_offense(<<-RUBY)
      require 'spec_helper'
      describe "bad describe" do
               ^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
    RUBY
  end

  it 'checks highlights the first argument of a describe' do
    expect_offense(<<-RUBY)
      describe "bad describe", "blah blah" do
               ^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
    RUBY
  end

  it 'ignores nested describe statements' do
    expect_no_offenses(<<-RUBY)
      describe Some::Class do
        describe "bad describe" do
        end
      end
    RUBY
  end

  context 'when argument is a String literal' do
    it 'ignores class without namespace' do
      expect_no_offenses(<<-RUBY)
        describe 'Thing' do
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'ignores class with namespace' do
      expect_no_offenses(<<-RUBY)
        describe 'Some::Thing' do
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'ignores value constants' do
      expect_no_offenses(<<-RUBY)
        describe 'VERSION' do
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'ignores value constants with namespace' do
      expect_no_offenses(<<-RUBY)
        describe 'Some::VERSION' do
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'ignores top-level constants with `::` at start' do
      expect_no_offenses(<<-RUBY)
        describe '::Some::VERSION' do
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'checks `camelCase`' do
      expect_offense(<<-RUBY)
        describe 'activeRecord' do
                 ^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'checks numbers at start' do
      expect_offense(<<-RUBY)
        describe '2Thing' do
                 ^^^^^^^^ The first argument to describe should be the class or module being tested.
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end

    it 'checks empty strings' do
      expect_offense(<<-RUBY)
        describe '' do
                 ^^ The first argument to describe should be the class or module being tested.
          subject { Object.const_get(self.class.description) }
        end
      RUBY
    end
  end

  context 'when IgnoredMetadata is empty' do
    let(:cop_config) { { 'IgnoredMetadata' => {} } }

    it 'flags metadata' do
      expect_offense(<<-RUBY)
      describe 'my new feature', type: :feature do
               ^^^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
      RUBY
    end
  end

  context 'when IgnoredMetadata is configured' do
    let(:cop_config) do
      {
        'IgnoredMetadata' => {
          'type' => %w[feature request],
          'foo' => %w[bar]
        }
      }
    end

    it 'ignores configured feature type metadata' do
      expect_no_offenses(<<-RUBY)
      describe 'my new system test', type: :feature do
      end
      RUBY
    end

    it 'ignores configured request type metadata' do
      expect_no_offenses(<<-RUBY)
      describe 'my new system test', type: :request do
      end
      RUBY
    end

    it 'ignores configured foo metadata' do
      expect_no_offenses(<<-RUBY)
      describe 'my new system test', foo: :bar do
      end
      RUBY
    end

    it 'ignores request type metadata when RSpec.describe is used' do
      expect_no_offenses(<<-RUBY)
      RSpec.describe 'my new feature', type: :feature do
      end
      RUBY
    end

    it 'flags request type metadata when passed as strings' do
      expect_offense(<<-RUBY)
      describe 'my new feature', 'type' => 'feature' do
               ^^^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
      RUBY
    end

    it 'flags specs with non configured metadata' do
      expect_offense(<<-RUBY)
      describe 'my new feature', foo: :feature do
               ^^^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
      RUBY
    end

    it 'flags specs with non configured values' do
      expect_offense(<<-RUBY)
      describe 'my new feature', type: :unit do
               ^^^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
      RUBY
    end

    it 'flags specs with mixed configured values' do
      expect_offense(<<-RUBY)
      describe 'my new feature', foo: :request do
               ^^^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
      RUBY
    end

    it 'flags normal metadata in describe' do
      expect_offense(<<-RUBY)
      describe 'my new feature', blah, type: :wow do
               ^^^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
      RUBY
    end

    it 'flags method call' do
      expect_offense(<<-RUBY)
      describe 'my new feature', blah, type: feature do
               ^^^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
      RUBY
    end

    it 'flags arithmetic operation' do
      expect_offense(<<-RUBY)
      describe 'my new feature', blah, type: 'fea' + 'ture' do
               ^^^^^^^^^^^^^^^^ The first argument to describe should be the class or module being tested.
      end
      RUBY
    end

    it 'ignores configured metadata also with complex options' do
      expect_no_offenses(<<-RUBY)
      describe 'my new feature', :test, :type => :model, :foo => :bar do
      end
      RUBY
    end
  end

  it 'ignores an empty describe' do
    expect_no_offenses(<<-RUBY)
      RSpec.describe do
      end

      describe do
      end
    RUBY
  end

  it "doesn't blow up on single-line describes" do
    expect_no_offenses('describe Some::Class')
  end

  it "doesn't flag top level describe in a shared example" do
    expect_no_offenses(<<-RUBY)
      shared_examples 'Common::Interface' do
        describe '#public_interface' do
          it 'conforms to interface' do
            # ...
          end
        end
      end
    RUBY
  end

  it "doesn't flag top level describe in a shared context" do
    expect_no_offenses(<<-RUBY)
      RSpec.shared_context 'Common::Interface' do
        describe '#public_interface' do
          it 'conforms to interface' do
            # ...
          end
        end
      end
    RUBY
  end

  it "doesn't flag top level describe in an unnamed shared context" do
    expect_no_offenses(<<-RUBY)
      shared_context do
        describe '#public_interface' do
          it 'conforms to interface' do
            # ...
          end
        end
      end
    RUBY
  end
end
