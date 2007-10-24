#!/usr/local/bin/pl -s

:- use_module(onto_spec).
:- use_module(library('semweb/rdf_db')).
:- use_module(library('semweb/rdf_turtle')).

:- rdf_load('../chordontology.rdfs').

author_name('Christopher Sutton').
author_foaf('http://chrissutton.org/me').
page_title('Chord Ontology Specification').

/*:- gen('../doc/chordontology.html').*/

output('../doc/chordontology.html').

:-  output(Output),
	open(Output,write,Otp),
	header(Header),
	write(Otp,Header),
	open('../doc/1-intro.htm',read,Introduction),
	copy_stream_data(Introduction, Otp),
	open('../doc/2-model.htm',read,Model),
	copy_stream_data(Model, Otp),
	open('../doc/3-glance.htm',read,GlanceIntro),
	copy_stream_data(GlanceIntro, Otp),
	glance_html_desc(Glance),
	write(Otp,Glance),
	open('../doc/4-spec.htm',read,SpecIntro),
	copy_stream_data(SpecIntro, Otp),
	classes_html_desc(Classes),
	write(Otp,Classes),
	props_html_desc(Props),
	write(Otp,Props),
	inds_html_desc(Inds),
	write(Otp,Inds),
	deprecs_html_desc(Deprecs),
	write(Otp,Deprecs),
	close(Otp),
	rdf_db:rdf_retractall(_,_,_).

:- halt.
