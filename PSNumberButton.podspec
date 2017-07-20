Pod::Spec.new do |s|
  s.name         = "PSNumberButton"
  s.version      = "1.0.0"
  s.summary      = "The package of useful tools, include categories and classes"
  s.homepage     = "https://github.com/heqinqin/PSNumberButton"
  s.license      = "MIT"
  s.authors      = { 'heqinqin' => '546551235@qq.com'}
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/heqinqin/PSNumberButton.git", :tag => s.version }
  s.source_files = 'PSNumberButton', 'PSNumberButton/*.{h,m}'
  s.requires_arc = true
end