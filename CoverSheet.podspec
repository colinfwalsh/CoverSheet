Pod::Spec.new do |s|
  s.name             = 'CoverSheet'
  s.version          = '0.1.2'
  s.summary          = 'A reusable bottom sheet with customizable stops. Usable with both UIKit and SwiftUI.'
  s.homepage         = 'https://github.com/colinfwalsh/CoverSheet'
  s.license          = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author           = { 'Colin Walsh' => 'colinfwalsh@gmail.com' }
  s.source           = { :git => 'https://github.com/colinfwalsh/CoverSheet.git', :tag => 'v0.1.2' }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/CoverSheet/**/*'
end
