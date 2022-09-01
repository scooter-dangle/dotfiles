function __fish_complete_cd -d "Completions for the cd command"
	# set -l token (commandline -ct)
	set --local token (commandline --cut-at-cursor --current-token)

	# Absolute path or explicitly from the current directory - no descriptions and no CDPATH
	# if string match -qr '^\.?\.?/.*' -- $token
	if string match --quiet --regex '^\.?\.?/.*' -- $token
		for d in $token*/
			# Check if it's accessible - the glob only matches directories
			[ -x $d ]; and printf "%s\n" $d
		end
	else # Relative path - check $CDPATH and use that as description
		# set -l cdpath $CDPATH
		set --local cdpath $CDPATH
		[ -z "$cdpath" ]; and set cdpath "."
		# Remove the real path to "." (i.e. $PWD) from cdpath if we're in it
		# so it doesn't get printed in the descriptions
		# if set -l ind (contains -i -- $PWD $cdpath)
		if set --local ind (contains --index -- $PWD $cdpath)
			and contains -- "." $cdpath
			# set -e cdpath[$ind]
			set --export cdpath[$ind]
		end
		# TODO: There's a subtlety regarding descriptions - if $cdpath[1]/foo and $cdpath[2]/foo exist, we print both
		# but want the first description to win - this currently works, but is not guaranteed
		for i in $cdpath
			# set -l desc
			set --local desc
			# Don't show description for current directory
			# and replace $HOME with "~"
			# [ $i = "." ]; or set -l desc (string replace -r -- "^$HOME" "~" "$i")
			[ $i = "." ]; or set --local desc (string replace --regex -- "^$HOME" "~" "$i")
			# This assumes the CDPATH component itself is cd-able
			for d in $i/$token*/
				# Remove the cdpath component again
				# [ -x $d ]; and printf "%s\t%s\n" (string replace -r "^$i/" "" -- $d) $desc
				[ -x $d ]; and printf "%s\t%s\n" (string replace --regex "^$i/" "" -- $d) $desc
			end
		end
	end
end


# Formerly used modification of the original function to prevent obscene pauses
# due to running hooks associated with change in `$PWD`
# function __fish_complete_cd --description '(fixed) Completions for the cd command'
# 	#
# 	# We can't simply use __fish_complete_directories because of the CDPATH
# 	#
# 	set -l wd $PWD

# 	# Check if CDPATH is set

# 	set -l mycdpath

# 	if test -z $CDPATH[1]
# 		set mycdpath .
# 	else
# 		set mycdpath $CDPATH
# 	end

# 	# Note how this works: we evaluate $ctoken*/
# 	# That trailing slash ensures that we only expand directories

# 	set -l ctoken (commandline -ct)
# 	if echo $ctoken | sgrep '^/\|^\./\|^\.\./\|^~/' >/dev/null
# 		# This is an absolute search path
# 		# Squelch descriptions per issue 254
# 		eval printf '\%s\\n' $ctoken\*/
# 	else
# 		# This is a relative search path
# 		# Iterate over every directory in CDPATH
# 		# and check for possible completions

# 		for i in $mycdpath
# 			# Move to the initial directory first,
# 			# in case the CDPATH directory is relative
# 			# builtin cd $wd ^/dev/null
# 			__fish_skip_config "builtin cd $wd" ^/dev/null
# 			# builtin cd $i ^/dev/null
# 			__fish_skip_config "builtin cd $i" ^/dev/null

# 			if test $status -ne 0
# 				# directory does not exists or missing permission
# 				continue
# 			end

# 			# What we would really like to do is skip descriptions if all
# 			# valid paths are in the same directory, but we don't know how to
# 			# do that yet; so instead skip descriptions if CDPATH is just .
# 			if test "$mycdpath" = .
# 				eval printf '"%s\n"' $ctoken\*/
# 			else
# 				eval printf '"%s\tin "'$i'"\n"' $ctoken\*/
# 			end
# 		end
# 	end

# 	__fish_skip_config "builtin cd $wd" ^/dev/null
# end
