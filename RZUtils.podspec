Pod::Spec.new do |s|
  s.name         = "RZUtils"
  s.version      = "2.1.1"
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
  
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/Raizlabs/RZUtils.git", :tag => "2.1.1" }
  s.requires_arc = true
  s.frameworks   = "Foundation", "UIKit"
  
  s.default_subspec = 'All'
  
  #
  # Category Subspecs
  #
  
  s.subspec "Categories" do |ss|
    
    ss.subspec "CoreAnimation" do |sss|
      sss.source_files = "RZUtils/Categories/CoreAnimation/*.{h,m}"
      sss.frameworks   = "QuartzCore"
    end
    
    ss.subspec "KVO" do |sss|
      sss.source_files = "RZUtils/Categories/KVO/*.{h,m}"
    end
    
    ss.subspec "NSDate" do |sss|
      sss.source_files = "RZUtils/Categories/NSDate/*.{h,m}"
    end
  
    ss.subspec "NSDictionary" do |sss|
      sss.source_files = "RZUtils/Categories/NSDictionary/*.{h,m}"
    end
  
    ss.subspec "NSString" do |sss|
      sss.source_files = "RZUtils/Categories/NSString/*.{h,m}"
    end
  
    ss.subspec "NSUndoManager" do |sss|
      sss.source_files = "RZUtils/Categories/NSUndoManager/*.{h,m}"
    end
  
    ss.subspec "UIAlertView" do |sss|
      sss.source_files = "RZUtils/Categories/UIAlertView/*.{h,m}"
    end
    
    ss.subspec "UIColor" do |sss|
      sss.source_files = "RZUtils/Categories/UIColor/*.{h,m}"
    end
  
    ss.subspec "UIFont" do |sss|
      sss.source_files = "RZUtils/Categories/UIFont/*.{h,m}"
    end
  
    ss.subspec "UIImage" do |sss|
      sss.source_files = "RZUtils/Categories/UIImage/*.{h,m}"
    end
  
    ss.subspec "UIImageView" do |sss|
      sss.source_files = "RZUtils/Categories/UIImageView/*.{h,m}"
    end
  
    ss.subspec "UIView" do |sss|
      sss.source_files = "RZUtils/Categories/UIView/*.{h,m}"
    end
    
    ss.subspec "UIViewController" do |sss|
      sss.source_files = "RZUtils/Categories/UIViewController/*.{h,m}"
    end
    
  end
  
  #
  # Component Subspecs
  #
  
  s.subspec "Components" do |ss|
    
    ss.subspec "RZAnimatedCountingLabel" do |sss|
      sss.source_files = "RZUtils/Components/RZAnimatedCountingLabel/*.{h,m}"
      sss.frameworks = "QuartzCore"
    end
    
    ss.subspec "RZAnimatedImageView" do |sss|
      sss.source_files = "RZUtils/Components/RZAnimatedImageView/*.{h,m}"
      sss.frameworks = "QuartzCore"
    end
    
    ss.subspec "RZButtonView" do |sss|
      sss.source_files = "RZUtils/Components/RZButtonView/*.{h,m}"
    end
    
    ss.subspec "RZCollectionTableView" do |sss|
      sss.source_files = "RZUtils/Components/RZCollectionTableView/*.{h,m}"
      sss.private_header_files = "RZUtils/Components/RZCollectionTableView/*Private.h"
    end
    
    ss.subspec "RZCollectionViewAnimationAssistant" do |sss|
      sss.source_files = "RZUtils/Components/RZCollectionViewAnimationAssistant/*.{h,m}"
    end
    
    ss.subspec "RZDelayedOperation" do |sss|
      sss.source_files = "RZUtils/Components/RZDelayedOperation/*.{h,m}"
    end
    
    ss.subspec "RZLocationService" do |sss|
      sss.source_files = "RZUtils/Components/RZLocationService/*.{h,m}"
      sss.frameworks = "CoreLocation"
    end
    
    ss.subspec "RZProgressView" do |sss|
      sss.source_files = "RZUtils/Components/RZProgressView/*.{h,m}"
    end
    
    ss.subspec "RZRevealViewController" do |sss|
      sss.source_files = "RZUtils/Components/RZRevealViewController/*.{h,m}"
    end
    
    ss.subspec "RZSegmentedViewController" do |sss|
      sss.source_files = "RZUtils/Components/RZSegmentedViewController/*.{h,m}"
    end
    
    ss.subspec "RZSingleChildContainerViewController" do |sss|
      sss.source_files = "RZUtils/Components/RZSingleChildContainerViewController/*.{h,m}"
    end
    
    ss.subspec "RZSplitViewController" do |sss|
      sss.source_files = "RZUtils/Components/RZSplitViewController/*.{h,m}"
    end
    
    ss.subspec "RZTelprompt" do |sss|
      sss.source_files = "RZUtils/Components/RZTelprompt/*.{h,m}"
    end
    
    ss.subspec "RZViewFactory" do |sss|
      sss.source_files = "RZUtils/Components/RZViewFactory/*.{h,m}"
    end
    
    ss.subspec "RZWebViewController" do |sss|
      sss.source_files = "RZUtils/Components/RZWebViewController/*.{h,m}"
    end
    
  end
  
  #
  # Utility Subspecs
  #
  
  s.subspec "TestUtilities" do |ss|
    
    ss.subspec "RZWaiter" do |sss|
      sss.source_files = "RZUtils/Test Utilities/RZWaiter/*.{h,m}"
    end
    
  end
  
  s.subspec "Utilities" do |ss|
    
    ss.subspec "RZCommonUtils" do |sss|
      sss.source_files = "RZUtils/Utility/RZCommonUtils/*.{h,m}"
    end
    
    ss.subspec "RZDispatch" do |sss|
      sss.source_files = "RZUtils/Utility/RZDispatch/*.{h,m}"
    end
    
  end
  
  #
  # Catch-all subspec
  # NOTE: Test utils not included here
  #
  
  s.subspec "All" do |ss|
    ss.dependency 'RZUtils/Categories'
    ss.dependency 'RZUtils/Components'
    ss.dependency 'RZUtils/Utilities'
  end

end
