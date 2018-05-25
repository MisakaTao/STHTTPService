#
# Be sure to run `pod lib lint STHTTPService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'STHTTPService'
  s.version          = '0.1.0'
  s.summary          = 'AFNetworking 与 YYCache 二次封装网络请求，方便管理请求 task，和缓存。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/misakatao/STHTTPService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'misakatao' => 'misakatao@yahoo.co.jp' }
  s.source           = { :git => 'https://github.com/misakatao/STHTTPService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  
  s.subspec 'HTTPService' do |sp|
      sp.source_files = 'STHTTPService/Classes/**/*.{h,m}'
      sp.public_header_files = 'STHTTPService/Classes/**/*.{h}'
      
      sp.dependency 'AFNetworking'
      sp.dependency 'YYModel'
      sp.dependency 'YYCache'
  end
  
  # s.resource_bundles = {
  #   'STHTTPService' => ['STHTTPService/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
