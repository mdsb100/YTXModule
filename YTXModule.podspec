#
# Be sure to run `pod lib lint YTXModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YTXModule'
  s.version          = '1.2.3'
  s.summary          = 'YTXModule 组件化'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = '组件化可以获得App生命周期，并且可以收发消息'

  s.homepage         = 'http://gitlab.yintech.net/ytx-ios/YTXModule.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'caojun' => '78612846@qq.com' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  ytx_zipURL='http://ios-pod.baidao.com/binaryfiles/YTXModule.zip'

  if ENV['IS_SOURCE'] || ENV["#{s.name}_SOURCE"]
      s.source           = { :git => 'http://gitlab.yintech.net/ytx-ios/YTXModule.git', :tag => s.version.to_s }
  else
      s.source           = { :http => ytx_zipURL}
  end

  if ENV['IS_SOURCE'] || ENV["#{s.name}_SOURCE"]
      s.prepare_command = <<-'END'
        test -f download_zip.sh && sh download_zip.sh YTXModule
      END

      puts '-------------------------------------------------------------------'
      puts "Notice:#{s.name} is source now"
      puts '-------------------------------------------------------------------'
      s.source_files = "#{s.name}/Classes/**/*"
  else
      puts '-------------------------------------------------------------------'
      puts "Notice:#{s.name} is binary now"
      puts '-------------------------------------------------------------------'
      s.source_files = "#{s.name}/Classes/*.h"
      s.public_header_files = "#{s.name}/Classes/*.h"
      s.ios.vendored_libraries = "#{s.name}/lib/lib#{s.name}.a"
  end
  s.preserve_paths = "#{s.name}/lib/lib#{s.name}.a","#{s.name}/Classes/**/*", "download_zip.sh"

  if ENV['NO_DEPENDENCY']
      puts '-------------------------------------------------------------------'
      puts "Notice:#{s.name} no dependency now"
      puts '-------------------------------------------------------------------'
  else
      puts '-------------------------------------------------------------------'
      puts "Notice:#{s.name} has dependency now!(dependency is empty!)"
      puts '-------------------------------------------------------------------'
  end

  s.frameworks = 'Foundation', 'UIKit'

end
