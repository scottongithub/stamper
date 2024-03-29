#!/bin/bash

# email address to be displayed in shell for copy/paste purposes
email=""

# originstamp API key; leave empty to bypass
originstamp_key=""

source_dir=""
dest_dir=""

# Associative array mapping timestamping authority (key) to their API URL (val)
# the keys will be used in filenaming
# a good resource for finding TSA's is https://gist.github.com/Manouchehri/fd754e402d98430243455713efada710
declare -A tsa_to_url
tsa_to_url[free_tsa]="https://freetsa.org/tsr"
tsa_to_url[safe_creative]="http://tsa.safecreative.org"
tsa_to_url[digicert]="http://timestamp.digicert.com"
tsa_to_url[apple]="http://timestamp.apple.com/ts01"

cd $source_dir
for file in *.*; do

  # strip file extension and store as 'name'
  name=$(echo "$file" | cut -f 1 -d '.')
  final_dest_dir=$dest_dir/$name
  if [[ ! -d $final_dest_dir ]]; then
      mkdir $final_dest_dir

      gpg --sign $file
      file_signed=$(ls -1 $name.*.gpg | head -n1)

      # make a sha256 of it and store in a text file whose name is also the hash
      sha256=$(sha256sum $file_signed | cut -f 1 -d ' ')
      echo $sha256 > "$final_dest_dir/$sha256"

      # create a RFC 3161 time-stamp query
      openssl ts -query -data $file_signed -no_nonce -sha512 -cert -out "$final_dest_dir/${name}.tsq"

      # iterate on timestamp authorities and for each store the result in a file with the TA name appended
      # with associative arrays here, a ! first refers to keys and without ! refers to values
      for timestamping_authority in "${!tsa_to_url[@]}"; do
        printf "\n$name\n${tsa_to_url[$timestamping_authority]}\n"
        curl -H "Content-Type: application/timestamp-query" \
          --data-binary "@${final_dest_dir}/${name}.tsq" "${tsa_to_url[@]}" > \
          "$final_dest_dir/${name}_${timestamping_authority}.tsr"
      done

      #post to originstamp via API
      curl -X POST "https://api.originstamp.com/v4/timestamp/create" \
          -H "accept: application/json" \
          -H "Authorization: $originstamp_key" \
          -H "Content-Type: application/json" \
          -d '{"comment": "'"$name"'", "hash": "'"$sha256"'", "notifications": [{"curreny": 0, "notification_type": 0, "target": "'"$email"'"}]}' \
          | tee -a "$final_dest_dir/${name}.log"

  else
    echo "Looks like $file has already been done - please rename it if you'd like to stamp/archive it"
  fi

  # add name and its hash to a report that prints to console for easy cut-paste into whatever
  echo $name >> /tmp/stamper_report.txt
  echo $sha256 >> /tmp/stamper_report.txt
  echo >> /tmp/stamper_report.txt
  mv $file "$final_dest_dir/$file"
  mv $file_signed "$final_dest_dir/$file_signed"
  gpg --export -a > "$final_dest_dir/gpg_public_key.txt"
done

# prints hashes and email address for easier copy-pasting into non RFC 3161 stampers
echo
printf "\n$email\n\n"
cat /tmp/stamper_report.txt
rm /tmp/stamper_report.txt
