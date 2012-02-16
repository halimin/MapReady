#!/usr/bin/perl
#
# Turn the enum definitions in enum.h into a set of tables, so the
#  same information can be looked up by C code at runtime.
# Orion Sky Lawlor, olawlor@acm.org, 2006/07/13 (ASF)
#
use strict;

open(HEADER,"<enum.h") or die("Could not open enum.h file.");
open(CODE,">enum_table.cpp") or die("Could not create enum_table.cpp file.");

print CODE '/** Enum-to-string tables automatically generated by enum_parse.pl from enum.h--
   DO NOT EDIT THIS FILE!  Edit enum.h and re-run enum_parse.pl instead!
enum_parse.pl last regenerated this file on '.`date`.'*/
#include "asf_meta/util.h"
#include "asf_meta/enum.h"
';

# Perl trim function to remove whitespace from the start and end of the string
#  from http://www.somacon.com/p114.php
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

# Walk through HEADER, creating CODE tables of the enums we find:
my $inEnum=0; # If true, we're inside an enum's curly braces.
my $enumTable=""; # Enum table being built. Contains C code.
my $lineCount=0;
foreach my $line (<HEADER>) {
    chomp($line);              # remove the newline from $line.
    $lineCount++;
   # print "Line $lineCount: $line\n";
    if ($line =~ /^\s*typedef\s*enum\s*{/ ) { # Starting a new enum
        print "Starting enum on line $lineCount\n  ";
	$enumTable="";
    	$inEnum=1; 
    }
    elsif ($line =~ /^\s*}\s*(\w+)\s*;/ ) { # Close brace--done with enum.
        my $enumName=$1; # e.g., "foo_type_t"
        print "done with enum '$enumName' on line $lineCount\n";
	print CODE "const asf::enum_value_description_t asf::$enumName"."_table[]={\n";
	print CODE $enumTable;
	print CODE "  {-1,\"Unknown_value\",\"Unknown enum value\"}\n}; /* end table for $enumName */\n\n";
        $inEnum=0;
    } elsif ($inEnum == 1) { # Just a standard enum line
    	if ($line =~ /^\s*(\w+)[\s=0-9,]*(.*)\w*$/ ) { # It's a valid line 
		my $name=$1; # e.g., "SLANT_RANGE"
		my $comment=$2; # e.g., "/**< The distance from the satellite to the target (m) */"
		
		# Extract description from comment
		my $desc="";
		if ($comment =~ /^\/\*[\*]?[<]?(.*)\*\/$/ ) { $desc=trim($1); } # /** C comment */
		if ($comment =~ /^\/[\/]+[<]?(.*)$/ ) { $desc=trim($1); } # // C++ comment
		
		# Escape dangerous string characters in description
		$desc =~ s/\"/\\\"/g;
		
		print ".";
		$enumTable = $enumTable . "  { $name,\t\"$name\",\t\"$desc\"},\n";
		# print "  Name '$name'   desc '$desc' on line $lineCount\n";
	}
    }
}