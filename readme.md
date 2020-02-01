# Overview
## Purpose
To timestamp files, both directly with trusted timestamping authorities (TSAs), and indirectly by outputting-to-console both the file's sha256 hash and an email address for easy copy-paste into other services. Each file is turned into an archive with everything needed to recreate the chain from content to claim.

## What it does
It looks in the directory it was called from and iterates on all files in it:
- create an archive directory in the working directory, named after the current file
- create a sha256 hash of the current file and save it as a text file-->archive
- create a (RFC 3161) timestamp request of the current file (via openssl)-->archive  
- for every TSA listed in the config file, submit the timestamp request to the current TSA, append the current TSA name to its reply-->archive
- source file gets moved to archive


