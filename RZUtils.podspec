Pod::Spec.new do |s|
  s.name         = "RZUtils"
  s.version      = "2.0.0"
  s.summary      = "Commonly used iOS categories and components from the Raizlabs development team"

  s.description  = <<-DESC
                   RZUtils is a collection of categories and smaller components for iOS development
                   that are used by the Raizlabs development team in multiple applications. This library
                   will continue to grow as components are added, edited, deprecated and removed.
                   DESC

  s.homepage     = "https://github.com/Raizlabs/RZUtils"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors            = { "Stephen Barnes" => "stephen.barnes@raizlabs.com",
                           "Nick Bonatsakis" => "nick.bonatsakis@raizlabs.com",
                           "Nick Donaldson" => "nick.donaldson@raizlabs.com",
                           "Zev Eisenberg" => "zev.eisenberg@raizlabs.com",
                           "Andrew McKnight" => "andrew.mcknight@raizlabs.com",
                           "Alex Rouse" => "alex.rouse@raizlabs.com" }
  s.social_media_url   = "http://twitter.com/raizlabs"
  
  s.platform     = :ios
  s.source       = { :git => "https://github.com/Raizlabs/RZUtils.git", :tag => "2.0.0" }
  s.requires_arc = true

  # Category Subspecs
  
  # Component Subspecs
  
  # Utility Subspecs
  
  

end
