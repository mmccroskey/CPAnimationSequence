#
# Be sure to run `pod spec lint mmccroskey-CPAnimationSequence.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "mmccroskey-CPAnimationSequence"
  s.version      = "0.0.1"
  s.summary      = "mmccroskey's fork of CPAnimationSequence."
  s.homepage     = "http://github.com/mmccroskey/CPAnimationSequence"
  s.author       = { "Matthew McCroskey" => "matthew.mccroskey@gmail.com" }
  s.source       = { :git => "http://github.com/mmccroskey/CPAnimationSequence.git", :tag => "0.0.1" }
  s.platform     = :ios, '5.0'
  s.source_files = 'Component'
  s.frameworks = 'Foundation', 'UIKit', 'CoreGraphics'
  s.requires_arc = true
  # Finally, specify any Pods that this Pod depends on.
  #
  # s.dependency 'JSONKit', '~> 1.4'
end
