# Overview
## Purpose
To sign and timestamp files, both directly with trusted timestamping authorities (TSAs) and OriginStamp, and indirectly by outputting-to-console both the (gpg-signed) file's sha256 hash and an email address for easy copy-paste into other services. Each file is turned into a folder archive with everything needed to recreate the chain from content to claim.

## What it does
It looks in the source directory and iterates on each file (with an extension):
- create an archive directory in the destination directory, named after the current file (e.g. "my_song.mp3" becomes a folder "my_song")
- sign the file with the default GPG profile and save it to the archive folder
- create a sha256 hash of the singed file and save it to the archive folder
- create a (RFC 3161) timestamp request of the signed file (via openssl)-->archive  
- for every TSA listed in tsa_to_url (associative array), submit the timestamp request to the current TSA, append the current TSA name to its reply-->archive
- submit the sha256 hash of the signed file to OriginStamp via API and log the results in the .log file-->archive
- source file gets moved to archive
