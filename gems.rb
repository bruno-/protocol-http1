# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in protocol-http1.gemspec
gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-bundler"
end
