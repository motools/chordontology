#!/usr/bin/env python
# encoding: utf-8
"""
labchords2RDF.py

A small script to generate timeline/chord ontology RDF corresponding to a .lab label file with
chord symbols as described in Harte, 2005 (ISMIR proceedings)

Created by Chris Sutton on 2007-09-14.
Copyright (c) 2007 Chris Sutton. All rights reserved.
"""

import mopy
from mopy.timeline import Interval, RelativeTimeLine
from mopy.chord import Chord
import rdflib
from urllib import quote as urlencode

from optparse import OptionParser

def labchords2RDF(infilename, outfilename, format="xml"):
	infile = open(infilename, 'r')
	lines = infile.readlines()

	mi = mopy.MusicInfo()

	homepage = mopy.foaf.Document("http://sourceforge.net/projects/motools")
	mi.add(homepage)
	program = mopy.foaf.Agent()
	program.name = "labchords2RDF.py"
	program.homepage = homepage
	mi.add(program)

	
	tl = RelativeTimeLine("tl")
	tl.label = "Timeline derived from "+infilename
	tl.maker = program
	mi.add(tl)
	
	intervalNum = 0
	for line in lines:
		i = Interval("i"+str(intervalNum))
		try:
			[start_s, end_s, label] = parseLabLine(line)
			i.beginsAtDuration = secondsToXSDDuration(start_s)
			i.endsAtDuration = secondsToXSDDuration(end_s)
			i.label = label
			i.onTimeLine = tl
			
			# Produce chord object for the label :
			chordURI = "http://purl.org/ontology/chord/symbol/"+urlencode(label)
			# FIXME : maybe deref to check it's a valid URI ?
			c = mopy.chord.Chord(chordURI)
			c_event = mopy.chord.ChordEvent("ce"+str(intervalNum))
			c_event.chord = c
			c_event.time = i
		except Exception, e:
			raise Exception("Problem parsing input file at line "+str(intervalNum+1)+" !\n"+str(e))
		mi.add(i)
		mi.add(c)
		mi.add(c_event)
		intervalNum+=1
			
	mopy.exportRDFFile(mi, outfilename, format)

def parseLabLine(line):
	"""Split a line from a .lab file into start time, end time and the label."""
	[start_s, end_s, label_w_cr] = line.split(None, 2)  # split by whitespace
	if label_w_cr[-1:] == "\n":
		label = label_w_cr[:-1]
	else:
		label = label_w_cr
	return [start_s, end_s, label]
	

def secondsToXSDDuration(s):
	"""Return an xsd:duration string for the given number of seconds."""
	return "P"+str(float(s))+"S"

if __name__ == '__main__':

	usage = "%prog [options] infile.lab [outfile.rdf]"
	parser = OptionParser(usage=usage)
	parser.add_option("--format", action="store", type="string", dest="format", \
						help="format for output (xml or n3)", metavar="FORMAT", default="xml")
	(opts,args) = parser.parse_args()
	
	if len(args) < 1 or len(args) > 2:
		parser.error("Wrong number of arguments !")
	else:
		infilename = args[0]
		
	if len(args) == 1:
		dotpos=infilename.rfind(".")
		if dotpos == -1:
			outfilename = infilename+".rdf"
		else:
			outfilename = infilename[:dotpos]+".rdf"
	else:
		outfilename = args[1]
	
	validFormats=["xml", "n3"]
	if opts.format not in validFormats:
		parser.error("Invalid format specified ! Must be one of : "+", ".join(validFormats))

	labchords2RDF(infilename, outfilename, opts.format)