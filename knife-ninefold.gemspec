$:.unshift(File.dirname(__FILE__) + '/lib')
require 'knife-ninefold/version'

Gem::Specification.new do |s|
  s.name = 'knife-ninefold'
  s.version = KnifeNinefold::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md"]
  s.summary = "Ninefold Support for Chef's Knife Command"
  s.description = s.summary
  s.author = "Lincoln Stoll"
  s.email = "lstoll@lstoll.net"

  s.add_dependency "chef"
  s.add_dependency "fog"
  s.require_path = 'lib'
  s.files = %w(README.md) + Dir.glob("lib/**/*")
end
