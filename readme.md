# Overview
## Purpose
To sign and timestamp files, both directly with trusted timestamping authorities (TSAs) and OriginStamp, and indirectly by outputting-to-console both the (gpg-signed) file's sha256 hash and an email address for easy copy-paste into other services. Each file is turned into a folder archive with everything needed to recreate the chain from content to claim.

## How it Works
It looks in the source directory and iterates on each file (that has an extension and no whitespace):
- create an archive directory in the destination directory, named after the current file (e.g. "my_song.mp3" becomes a folder "my_song")
- sign the file with the default GPG profile and save it to the archive folder
- create a sha256 hash of the signed file and save it to the archive folder
- create a (RFC 3161) timestamp request of the signed file (via openssl)-->archive  
- for every TSA listed in tsa_to_url (associative array at the top of the script), submit the timestamp request to the current TSA, append the current TSA name to its reply-->archive
- submit the sha256 hash of the signed file to OriginStamp via API and log the results in the .log file-->archive. If email address is added, the address will receive a notification from OriginStamp when the blockchain has been updated
- source file gets moved to archive

# Prerequisites
- openssl
- gnupg set up with default account
- OriginStamp account/API key if this service is to be used. Uses API v4

# Usage
Configuration is the top lines of `stamper.sh`: email (optional), OriginStamp API key (optional), source/destination directories.

Make it executable: `chmod +x stamper.sh`

Run it: `./stamper.sh`. If all goes well, the archive folder (for a source file `my_song.mp3` will look something like this:
```
.
..
2991ADF7A1FA5A377ECAB7447F1E2500C615160DB6D73BD86EAF53B4ED26B5B7
gpg_public_key.txt
my_song_apple.tsr
my_song_digicert.tsr
my_song_free_tsa.tsr
my_song.gpg
my_song.log
my_song.mp3.gpg
my_song_safe_creative.tsr
my_song.tsq
```
