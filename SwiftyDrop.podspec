Pod::Spec.new do |s|
  s.name         = "SwiftyDrop"
  s.version      = "0.0.1"
  s.summary      = "Lightweight dropdown menu in Swift. It's simple and beautiful."

  s.description  = <<-DESC
                   A longer description of SwiftyDrop in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/morizotter/SwiftyDrop"
  s.license      = "MIT"
  s.author       = { "Naoki Morita" => "namorit@gmail.com" }
  s.social_media_url   = "http://twitter.com/morizotter"
  s.source       = { :git => "https://github.com/morizotter/SwiftyDrop.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.1'
  s.requires_arc = true
  s.source_files = 'SwiftyDrop/**/*.swift'
end
