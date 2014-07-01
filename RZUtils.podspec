Pod::Spec.new do |s|
  s.name         = "RZUtils"
  s.version      = "2.0.0"
  s.summary      = "Commonly used iOS categories and components from the Raizlabs development team"

  s.description  = <<-DESC
                   RZUtils is a collection of categories and smaller components for iOS development
                   that are used by the Raizlabs development team in multiple applications. This library
                   will continue to grow as components are added, edited, deprecated and removed.
                   
                   See the README for more details on the individual components.
                   DESC

  s.homepage     = "https://github.com/Raizlabs/RZUtils"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  
  s.authors      = { "Stephen Barnes" => "stephen.barnes@raizlabs.com",
                     "Nick Bonatsakis" => "nick.bonatsakis@raizlabs.com",
                     "Nick Donaldson" => "nick.donaldson@raizlabs.com",
                     "Zev Eisenberg" => "zev.eisenberg@raizlabs.com",
                     "Andrew McKnight" => "andrew.mcknight@raizlabs.com",
                     "Alex Rouse" => "alex.rouse@raizlabs.com" }
                           
  s.social_media_url   = "http://twitter.com/raizlabs"
  
  s.platform     = :ios
  s.source       = { :git => "https://github.com/Raizlabs/RZUtils.git", :tag => "2.0.0" }
  s.requires_arc = true
  s.frameworks   = "Foundation", "UIKit"
  
  s.default_subspec = 'All'
  
  #
  # Category Subspecs
  #
  
  s.subspec "Categories" do |ss|
    
    ss.dependency 'RZUtils/Categories/CoreAnimation'
    ss.subspec "CoreAnimation" do |sss|
      sss.source_files = "RZUtils/Categories/CoreAnimation/*.{h,m}"
      sss.frameworks   = "QuartzCore"
    end
    
    ss.dependency 'RZUtils/Categories/KVO'
    ss.subspec "KVO" do |sss|
      sss.source_files = "RZUtils/Categories/KVO/*.{h,m}"
    end
    
    ss.dependency 'RZUtils/Categories/NSDate'
    ss.subspec "NSDate" do |sss|
      sss.source_files = "RZUtils/Categories/NSDate/*.{h,m}"
    end
  
    ss.dependency 'RZUtils/Categories/NSDictionary'
    ss.subspec "NSDictionary" do |sss|
      sss.source_files = "RZUtils/Categories/NSDictionary/*.{h,m}"
    end
  
    ss.dependency 'RZUtils/Categories/NSString'
    ss.subspec "NSString" do |sss|
      sss.source_files = "RZUtils/Categories/NSString/*.{h,m}"
    end
  
    ss.dependency 'RZUtils/Categories/NSUndoManager'
    ss.subspec "NSUndoManager" do |sss|
      sss.source_files = "RZUtils/Categories/NSUndoManager/*.{h,m}"
    end
  
    ss.dependency 'RZUtils/Categories/UIAlertView'
    ss.subspec "UIAlertView" do |sss|
      sss.source_files = "RZUtils/Categories/UIAlertView/*.{h,m}"
    end
    
    ss.dependency 'RZUtils/Categories/UIColor'
    ss.subspec "UIColor" do |sss|
      sss.source_files = "RZUtils/Categories/UIColor/*.{h,m}"
    end
  
    ss.dependency 'RZUtils/Categories/UIFont'
    ss.subspec "UIFont" do |sss|
      sss.source_files = "RZUtils/Categories/UIFont/*.{h,m}"
    end
  
    ss.dependency 'RZUtils/Categories/UIImage'
    ss.subspec "UIImage" do |sss|
      sss.source_files = "RZUtils/Categories/UIImage/*.{h,m}"
    end
  
    ss.dependency 'RZUtils/Categories/UIImageView'
    ss.subspec "UIImageView" do |sss|
      sss.source_files = "RZUtils/Categories/UIImageView/*.{h,m}"
    end
  
    ss.dependency 'RZUtils/Categories/UIView'
    ss.subspec "UIView" do |sss|
      sss.source_files = "RZUtils/Categories/UIView/*.{h,m}"
    end
    
    ss.dependency 'RZUtils/Categories/UIViewController'
    ss.subspec "UIViewController" do |sss|
      sss.source_files = "RZUtils/Categories/UIViewController/*.{h,m}"
    end
    
  end
  
  #
  # Component Subspecs
  #
  
  s.subspec "Components" do |ss|
    
  end
  
  #
  # Utility Subspecs
  #
  
  s.subspec "Utilities" do |ss|
    
  end
  
  # Catch-all subspec
  s.subspec "All" do |ss|
    ss.dependency 'RZUtils/Categories'
    ss.dependency 'RZUtils/Components'
    ss.dependency 'RZUtils/Utilities'
  end

end
