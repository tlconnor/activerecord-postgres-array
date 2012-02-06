Gem::Specification.new do |s|
  s.name = "activerecord-postgres-array"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Connor"]
  s.date = %q{2011-04-15}
  s.description = "Adds support for postgres arrays to ActiveRecord"
  s.email = "tim@youdo.co.nz"
  s.homepage = "https://github.com/tlconnor/activerecord-postgres-array"
  s.files = [
     "lib/activerecord-postgres-array.rb",
     "lib/activerecord-postgres-array/activerecord.rb",
     "lib/activerecord-postgres-array/array.rb",
     "lib/activerecord-postgres-array/string.rb"
  ]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = s.description

  s.add_dependency "rails"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.0'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'combustion', '~> 0.3.1'
end
