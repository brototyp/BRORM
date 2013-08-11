Pod::Spec.new do |s|

  s.name         = "BRORM"
  s.version      = "0.1"
  s.summary      = "Another Objective-C SQLite ORM"

  s.description  = <<-DESC
                   A longer description of BRORM in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/brototyp/BRORM"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Cornelius Horstmann" => "site-cocoapod@brototyp.de" }

  s.platform     = :ios
  s.platform     = :ios, '5.0'

  s.source       = { :git => "https://github.com/brototyp/BRORM.git", :tag => "0.1" }

  s.source_files  = 'BROrm/BRModel.{h,m}', 'BROrm/BROrm.{h,m}', 'BROrm/BRSegmetedString.{h,m}', 'BROrm/NSString+Inflections.{h,m}'

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = 'SomeFramework'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'

  # s.library   = 'iconv'
  # s.libraries = 'iconv', 'xml2'


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
  s.dependency 'FMDB', '~> 2.0'

end
