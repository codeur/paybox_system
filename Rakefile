# frozen_string_literal: true

require 'bundler/gem_tasks'

# module Bundler
#   class GemHelper
#     def rubygem_push(path)
#       gem_command = ["gem inabox #{path}"]
#       gem_command << '--key' << gem_key if gem_key
#       gem_command << '--host' << allowed_push_host if allowed_push_host
#       unless allowed_push_host || Bundler.user_home.join('.gem/credentials').file?
#         raise "Your rubygems.org credentials aren't set. Run `gem push` to set them."
#       end
#
#       sh(gem_command.join(' '))
#       Bundler.ui.confirm "Pushed #{name} #{version} to #{gem_push_host}"
#     end
#   end
# end

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task default: :spec
