Pod::Spec.new do |s|
  s.name             = "AFMActionSheet"
  s.version          = "1.1.0"
  s.summary          = "Easily adaptable action sheet supporting custom views and transitions."

  s.description      = <<-DESC
                       Easily adaptable action sheet supporting custom views and transitions.
                       AFMActionSheet provides a AFMActionSheetController that can be used in places where one would use a UIAlertController, but a customized apperance or custom presentation/dismissal animation is needed. Seeing as how AFMActionSheetController was inspired by UIAlertController, it too supports ActionSheet and Alert styles to make your life even easier.

                       DESC

  s.homepage         = "https://github.com/ask-fm/AFMActionSheet"
  s.screenshots      = "https://raw.githubusercontent.com/ask-fm/AFMActionSheet/master/res/action_sheet.gif", "https://raw.githubusercontent.com/ask-fm/AFMActionSheet/master/res/alert.gif"
  s.license          = 'MIT'
  s.author           = { "Ilya Alesker" => "ilya.alesker@ask.fm" }
  s.source           = { :git => "https://github.com/ask-fm/AFMActionSheet.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/evil_cormorant'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.frameworks = 'UIKit'
end
