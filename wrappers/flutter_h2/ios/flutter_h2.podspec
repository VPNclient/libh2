Pod::Spec.new do |s|
  s.name             = 'flutter_h2'
  s.version          = '0.1.0'
  s.summary          = 'H2 VPN Engine for Flutter'
  s.description      = <<-DESC
Flutter plugin for h2.core HTTPS VPN. Drop-in replacement for vpnclient_engine_flutter.
                       DESC
  s.homepage         = 'https://github.com/vpnclient/flutter_h2'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'NativeMind' => 'dev@nativemind.net' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'

  # H2Core framework (built with gomobile)
  s.vendored_frameworks = 'Frameworks/H2Core.xcframework'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
