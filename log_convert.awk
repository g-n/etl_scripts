# converts weechat-style logs into ivr format
# pass -v channel="$channel"
# outputs into ./out/[channel]/[date].txt
BEGIN {
	FS = "\t"
}

{
	split($1, datetime, " ")
	date = datetime[1]
	time = datetime[2]
	split(date, dates, "-")
	if (substr(dates[3], 1, 1) == "0") {
		outdate = "[" dates[1] "-" dates[2] "-" substr(dates[3], 2, 1) " " time "]"
	} else {
		outdate = "[" dates[1] "-" dates[2] "-" dates[3] " " time "]"
	}
	if ($2 == " *") {
		# "/me" messages
		st = index($3, " ")
		rem = substr($3, st + 1)
		start = substr($3, 0, st)
		gsub(/[ @%~]/, "", start)
		# print outdate" #"channel " " start": " rem
	} else if (substr($2, 0, 2) == "--") {
		# system join disconnect messages
	} else if ((substr($3, 0, 2) == "--") && ($2 == "")) {
		# channel messages
		new = substr($3, 4)
		st = index(new, " ")
		rem = substr(new, st + 1)
		start = substr(new, 0, st)
		gsub(/\047s/, "", start)
		gsub(/Chat Cleared By Moderator/, "has been banned", rem)
		if ((start == "Title ") && (start == "a ") && (substr(rem, 0, 7) == "raiders")) {
			next
			# print outdate" #"channel" " start rem
		}
	} else {
		start = $2
		gsub(/[ @%~]/, "", start)
		rem = $3
		# print outdate" #"channel" "$2": " $3
	}
	print(outdate " #" channel " " start ": " rem) > ("out/" channel "/" date ".txt")
}

