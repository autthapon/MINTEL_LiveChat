#
# Be sure to run `pod lib lint MINTEL_LiveChat.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MINTEL_LiveChat'
  s.version          = '1.0.30'
  s.summary          = 'MINTEL_LiveChat Library'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/autthapon/MINTEL_LiveChat/wiki'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'autthapon@gmail.com' => 'autthapon@gmail.com' }
  s.source           = { :git => 'https://github.com/autthapon/MINTEL_LiveChat.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'
  
  s.source_files = 'MINTEL_LiveChat/Classes/**/*'
  s.resources = "MINTEL_LiveChat/Assets/**/*"
  # s.resource_bundles = {
  #   'MINTEL_LiveChat' => ['MINTEL_LiveChat/Assets/*.png']
  # }
  s.dependency 'Alamofire', '~> 4.8.2'
  s.vendored_frameworks = 'MINTEL_LiveChat/Framework/ServiceCore.framework', 'MINTEL_LiveChat/Framework/ServiceChat.framework'
  s.preserve_paths = 'MINTEL_LiveChat/Framework/*'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'ServiceCore', 'ServiceChat'
  # s.dependency 'AFNetworking', '~> 2.3'
end
