# Overview
## Purpose
To sign and timestamp files, both directly with trusted timestamping authorities (TSAs) and OriginStamp, and indirectly by outputting-to-console both the (gpg-signed) file's sha256 hash and an email address for easy copy-paste into other services. Each file is turned into a folder archive with everything needed to recreate the chain from content to claim.

## How it Works

<p align="center">
<img src="https://user-images.githubusercontent.com/21364725/194717695-1f0d1d91-0d0b-4825-a072-b8d13d4395d3.png"/>
</p>

It looks in the source directory and iterates on each file (that has an extension and no whitespace):
- create an archive directory in the destination directory, named after the current file (e.g. "cool_song_6.mp3" becomes a folder "cool_song_6")
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

Run it: `./stamper.sh`. If all goes well, the archive folder (named after the source file) will look something like this:
```
username@hostname:~$ls -a cool_song_6
.
..
2991ADF7A1FA5A377ECAB7447F1E2500C615160DB6D73BD86EAF53B4ED26B5B7
gpg_public_key.txt
cool_song_6_apple.tsr
cool_song_6_digicert.tsr
cool_song_6_free_tsa.tsr
cool_song_6.gpg
cool_song_6.log
cool_song_6.mp3
cool_song_6.mp3.gpg
cool_song_6_safe_creative.tsr
cool_song_6.tsq
```

If you configured the OriginStamp key and email fields, then an email should be sent from OriginStamp once it has completed its transaction(s) with blockchain(s)
