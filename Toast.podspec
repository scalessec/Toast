Pod::Spec.new do |s|
  s.name         = "Toast"
  s.version      = "2.5"
  s.summary      = "A UIView category that adds Android-style toast notifications to iOS."
  s.homepage     = "https://github.com/Liron-K/Toast"
  s.license      = 'MIT'
  s.author       = { "Liron Kopinsky" => "liron.kopinsky@gmail.com" }
  s.source       = { :git => "https://github.com/Liron-K/Toast.git", :tag => "2.4" }
  s.platform     = :ios
  s.source_files = 'Toast/Toast'   
  s.framework    = 'QuartzCore'
  s.requires_arc = true
end
