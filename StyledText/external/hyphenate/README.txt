NSString+Hyphenate
by Eelco Lempsink


The Hyphenate category for NSString adds the method
-stringByHyphenatingWithLocale: which will (try to) return
the same string hyphenated with UTF-8 soft-hyphens.

The hyphenation itself is done using the 'hyphen' library
from the Hunspell project, which is also used by
OpenOffice.org.  To support hyphenation for different
languages, you can use the hyphenation dictionaries from the
OpenOffice.org project.


-- Setup

  * Step 1 : Download prerequisites
    
    Go to http://sourceforge.net/projects/hunspell/files/Hyphen/
    and download the latest version of the Hyphen library

    Download all the hyphenation libraries you want via
    http://wiki.services.openoffice.org/wiki/Dictionaries
    It might be easier to just pick the files from an FTP
    mirror, they're located in the contrib/dictionaries
    directory and all the file names start with 'hyph_'. 
    (http://ftp.snt.utwente.nl/pub/software/openoffice/contrib/dictionaries/)


  * Step 2 : Putting the code into place

    Add the NSString+Hyphenate .h and .m file to your
    project.

    To statically add the hyphen library to your project add
    the hyphen.h, hyphen.c and hnjalloc.h, hnjalloc.c files.


  * Step 3 : Adding dictionaries

    From the unzipped hyph_* files, copy the .dic file to
    the bundle directory Hyphenate.bundle.  
    
    If you are going to use language detection, you also
    need to provide the .dic files for just the language,
    not the language plus location (e.g. copy or symlink
    hyph_nl_NL.dic to hyph_nl.dic).

    Add the Hyphenate.bundle to your project.


-- Licensing

The NSString+Hyphenate code is licensed under the BSD3
license.  Hunspell is licensed under a GPL 2.0/LGPL 2.1/MPL 1.1
tri-license.  The licensing of the hyphenation libraries
differs and often there are multiple licenses available.
