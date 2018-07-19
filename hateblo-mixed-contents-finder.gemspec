
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hateblo_mixed_contents_finder/version"

Gem::Specification.new do |spec|
  spec.name          = "hateblo-mixed-contents-finder"
  spec.version       = HatebloMixedContentsFinder::VERSION
  spec.authors       = ["Junichi Ito"]
  spec.email         = ["me@jnito.com"]

  spec.summary       = %q{Helper tools for Hatena blog HTTPS migration}
  spec.homepage      = "https://github.com/JunichiIto/hateblo-mixed-contents-finder"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mechanize", "~> 2.7"
  spec.add_runtime_dependency "hatenablog", "~> 0.5"
  spec.add_runtime_dependency "thor", "~> 0.20"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "vcr", "~> 4.0"
  spec.add_development_dependency "webmock", "~> 3.4"
end
