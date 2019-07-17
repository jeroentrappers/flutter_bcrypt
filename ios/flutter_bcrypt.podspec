#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_bcrypt'
  s.version          = '0.0.1'
  s.summary          = 'A flutter bcrypt hashing plugin delegating to android &#x2F; ios native implementations.'
  s.description      = <<-DESC
A flutter bcrypt hashing plugin delegating to android &#x2F; ios native implementations.
                       DESC
  s.homepage         = 'https://github.com/jeroentrappers/flutter_bcrypt'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Jeroen Trappers' => 'jeroen@appmire.be' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'BCryptSwift', '~> 1.1'

  s.ios.deployment_target = '9.3'
end

