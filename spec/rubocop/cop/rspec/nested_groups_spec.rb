# frozen_string_literal: true

describe RuboCop::Cop::RSpec::NestedGroups, :config do
  subject(:cop) { described_class.new(config) }

  it 'flags nested contexts' do
    expect_violation(<<-RUBY)
      describe MyClass do
        context 'when foo' do
          context 'when bar' do
            context 'when baz' do
            ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded
            end
          end
        end

        context 'when qux' do
          context 'when norf' do
          end
        end
      end
    RUBY
  end

  it 'ignores non-spec context methods' do
    expect_no_violations(<<-RUBY)
      class MyThingy
        context 'this is not rspec' do
          context 'but it uses contexts' do
          end
        end
      end
    RUBY
  end

  context 'when Max is configured as 2' do
    let(:cop_config) { { 'Max' => '2' } }

    it 'flags two levels of nesting' do
      expect_violation(<<-RUBY)
        describe MyClass do
          context 'when foo' do
            context 'when bar' do
            ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded
              context 'when baz' do
              ^^^^^^^^^^^^^^^^^^ Maximum example group nesting exceeded
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when configured with MaxNesting' do
    let(:cop_config) { { 'MaxNesting' => '1' } }

    it 'emits a deprecation warning' do
      expect { inspect_source(cop, 'describe(Foo) { }', 'foo_spec.rb') }
        .to output(
          'Configuration key `MaxNesting` for RSpec/NestedGroups is ' \
          "deprecated in favor of `Max`. Please use that instead.\n"
        ).to_stderr
    end
  end
end
