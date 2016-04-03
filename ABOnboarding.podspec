Pod::Spec.new do |s|
  s.name             = "ABOnboarding"
  s.version          = "0.1.0"
  s.summary          = "The easiest way to onboard users in your iOS app"
  s.homepage         = "https://github.com/MrAdamBoyd/ABOnboarding"
  s.license          = 'MIT'
  s.author           = { "Adam Boyd" => "adamboyd50@gmail.com" }
  s.source           = { :git => "https://github.com/MrAdamBoyd/ABOnboarding.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ABOnboarding' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit', 'Foundation'
end
