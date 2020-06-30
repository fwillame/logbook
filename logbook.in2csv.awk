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

FNR ==  3 { byggdagar	= $38}		# byggdagar
FNR ==  3 { veckodag	= $44}		# veckodag
FNR ==  3 { veckonr	= $50}		# vecka nr.
FNR ==  6 { datum	= $46}		# datum

FNR>=26 && FNR<=43	{ print "\n" FILENAME, byggdagar, veckodag, veckonr, datum, $2, "egen",  $10}
FNR>=26 && FNR<=43	{ print "\n" FILENAME, byggdagar, veckodag, veckonr, datum, $2, "UE",    $12}
FNR>=44 && FNR<=44	{ print "\n" FILENAME, byggdagar, veckodag, veckonr, datum, $2, "total", $10}
