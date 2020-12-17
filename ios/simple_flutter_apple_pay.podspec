#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'simple_flutter_apple_pay'
  s.version          = '0.0.1'
  s.summary          = 'Simple Flutter Apple Pay'
  s.description      = <<-DESC
Simple Flutter Apple Pay
                       DESC
  s.homepage         = 'https://github.com/Code-Growers/simple-flutter-apple-pay.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Snailapp' => 'lada.zahradnik@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '9.0'
end

