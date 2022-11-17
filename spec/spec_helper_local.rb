# frozen_string_literal: true

def verify_exact_contents(subject, title, expected_lines)
  content = subject.resource('file', title).send(:parameters)[:content]
  expect(content.split("\n").reject { |line| line =~ %r{(^$|^#)} }).to eq(expected_lines)
end

def default_install_method(facts)
  return 'source' if facts[:os]['name'] == 'Debian' && facts[:os]['release']['major'].to_s == '10'

  'package'
end
