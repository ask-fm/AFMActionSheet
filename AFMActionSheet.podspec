Pod::Spec.new do |s|
  s.name             = "AFMActionSheet"
  s.version          = "0.1.0"
  s.summary          = "Simple action sheet with customizable appearance."

  s.description      = <<-DESC
                       Simple action sheet supporting custom views and transitions.

                       Action sheet apperance is specified by provinding actions as well as control for said action which must be a UIControl subclass.
                       Presentaion and dismissal transitions can be customized by providing a custom UIViewControllerTransitioningDelegate.

                       DESC

  s.homepage         = "https://github.com/ask-fm/AFMActionSheet"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Ilya Alesker" => "ilya.alesker@ask.fm" }
  s.source           = { :git => "https://github.com/ask-fm/AFMActionSheet.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/evil_cormorant'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.frameworks = 'UIKit'
end
