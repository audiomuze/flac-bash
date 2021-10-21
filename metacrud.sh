#!/bin/bash

search_dir() {
	cd "$1" || return
	count=$(ls -1 *.flac 2>/dev/null | wc -l)
	if [ $count != 0 ]; then
		echo "FLAC files found in "$PWD", invoking metaflac to remove crud..."
		metaflac --preserve-modtime --remove --block-type=PICTURE *.flac
		metaflac --preserve-modtime \
			--remove-tag="__albumgain" \
			--remove-tag="accurateripdiscid" \
			--remove-tag="accurateripresult" \
			--remove-tag="acoustid_fingerprint" \
			--remove-tag="album artist" \
			--remove-tag="album rating" \
			--remove-tag="albumartistsort" \
			--remove-tag="albumperformer" \
			--remove-tag="artists" \
			--remove-tag="artistsort" \
			--remove-tag="asin" \
			--remove-tag="band" \
			--remove-tag="catalog #" \
			--remove-tag="cdtoc" \
			--remove-tag="comment itunes_cddb_1" \
			--remove-tag="comment itunes_cddb_tracknumber" \
			--remove-tag="comment itunnorm" \
			--remove-tag="comment itunpgap" \
			--remove-tag="comment" \
			--remove-tag="composed by" \
			--remove-tag="composersort" \
			--remove-tag="copyright" \
			--remove-tag="description" \
			--remove-tag="discid" \
			--remove-tag="discs" \
			--remove-tag="disctotal" \
			--remove-tag="dr" \
			--remove-tag="encoded by" \
			--remove-tag="encoded-by" \
			--remove-tag="encodedby" \
			--remove-tag="encoder settings" \
			--remove-tag="encoder" \
			--remove-tag="encoding" \
			--remove-tag="hdtracks" \
			--remove-tag="info" \
			--remove-tag="iscompilation" \
			--remove-tag="itunesadvisory" \
			--remove-tag="isrc" \
			--remove-tag="language" \
			--remove-tag="mbrainz_country" \
			--remove-tag="mbrainz_rating" \
			--remove-tag="media" \
			--remove-tag="mediafoundationversion" \
			--remove-tag="notes" \
			--remove-tag="number" \
			--remove-tag="origartist" \
			--remove-tag="originalartist" \
			--remove-tag="packaging" \
			--remove-tag="position" \
			--remove-tag="publisher" \
			--remove-tag="quality" \
			--remove-tag="recodeby" \
			--remove-tag="release info" \
			--remove-tag="release type" \
			--remove-tag="release" \
			--remove-tag="releasestatus" \
			--remove-tag="replaygain_album_gain" \
			--remove-tag="replaygain_album_peak" \
			--remove-tag="replaygain_reference_loudness" \
			--remove-tag="replaygain_track_gain" \
			--remove-tag="replaygain_track_peak" \
			--remove-tag="retail date" \
			--remove-tag="rip date" \
			--remove-tag="ripping tool" \
			--remove-tag="script" \
			--remove-tag="showmovement" \
			--remove-tag="source" \
			--remove-tag="status" \
			--remove-tag="stream or buy on:" \
			--remove-tag="stream or buy on" \
			--remove-tag="t/r" \
			--remove-tag="tool name" \
			--remove-tag="tool version" \
			--remove-tag="totaldiscs" \
			--remove-tag="totaltracks" \
			--remove-tag="track-list" \
			--remove-tag="tracktotal" \
			--remove-tag="url" \
			--remove-tag="wm/originalreleasetime" \
			--remove-tag="wm/period" \
			--remove-tag="wm/provider" \
			--remove-tag="wm/providerrating" \
			--remove-tag="wm/providerstyle" \
			--remove-tag="writer" \
			*.flac

	fi

}

export -f search_dir
find "$PWD" -type d \( ! -name . \) -execdir bash -c 'search_dir "$0"' {} \;
