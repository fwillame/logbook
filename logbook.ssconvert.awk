#!/usr/bin/gawk -f

function get_date (timestamp) {
	t = mktime(gensub(/[\/:]/," ","g",timestamp))
	return strftime("%F", t)
	}

function get_time (timestamp) {
	t = mktime(gensub(/[\/:]/," ","g",timestamp))
	return strftime("%T", t)
	}

function get_type (path,i) {
	split(path,a,"/");
	return a[i]
	}


BEGIN{	FS="\t|\r|\n|,";
       	OFS="\t"; ORS="\t";
       	}

# NR == 1 { 		print     "filename", "NR", "FNR", "byggdagar",	"veckodag", "veckonr", "datum", "YA", "egen/ue", "antal"; next}

FNR ==  3 { byggdagar	= $37}		# byggdagar
FNR ==  3 { veckodag	= $43}		# veckodag
FNR ==  3 { veckonr	= $49}			# vecka nr.
FNR ==  6 { datum	= $45}			# datum

FNR>=26 && FNR<=43	{ print "\n" FILENAME, NR, FNR, byggdagar, veckodag, veckonr, datum, $1, "egen",   $9}
FNR>=26 && FNR<=43	{ print "\n" FILENAME, NR, FNR, byggdagar, veckodag, veckonr, datum, $1, "UE",    $11}
FNR>=44 && FNR<=44	{ print "\n" FILENAME, NR, FNR, byggdagar, veckodag, veckonr, datum, $1, "total",  $9}

