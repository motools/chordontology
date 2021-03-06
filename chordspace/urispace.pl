:- module(urispace,[init/0]).


:- use_module(library('http/thread_httpd')).
:- use_module(library('semweb/rdf_db')).
:- use_module(log).
:- use_module(chord_parser).

:- style_check(-discontiguous).

server(Port, Options) :-
        http_server(reply,[ port(Port),timeout(20)| Options]).




namespace('http://dbtune.org/chord').

/**
 * Handles documents
 */
reply(Request) :-
	member(path(Path),Request),
	atom_concat(SymbolT,'.rdf',Path),
	atom_concat('/',Symbol,SymbolT),
	!,
	(parse(Symbol,RDF) ->
		(
		current_output(S),
		set_stream(S,encoding(utf8)),
		format('Content-type: application/rdf+xml; charset=UTF-8~n~n', []),
		rdf_write_xml(S,RDF));
		(
		throw(http_reply(server_error('The specified chord symbol is not valid~n~n')))
		)).

/**
 * Sends back towards a png representation of the chord
 */
reply(Request) :-
	member(path(Path),Request),
	member(accept(AcceptHeader),Request),
	log:log('Accept header: ~w ',[AcceptHeader]),
	accept_png(AcceptHeader),
	!,
	atom_concat('/',Symbol,Path),
	(parse(Symbol,RDF) ->
		(
		member(rdf(_,'http://xmlns.com/foaf/0.1/depiction',Pic),RDF),
		throw(http_reply(see_other(Pic),[])));
		(
		throw(http_reply(server_error('The specified chord symbol is not valid~n~n')))
		)).
accept_png('image/png').



/**
 * Sends back 303 to RDF document describing the resource
 */
reply(Request) :-
	member(path(Path),Request),
	%member(accept(AcceptHeader),Request),
	accept_rdf(AcceptHeader),
	!,
	namespace(NS),
	format(atom(Redirect),'~w~w.rdf',[NS,Path]),
	log:log('Sending a 303 towards ~w',Redirect),
	throw(http_reply(see_other(Redirect),[])).

accept_rdf('application/rdf+xml').
accept_rdf('text/xml').
accept_rdf(AcceptHeader) :-
	sub_atom(AcceptHeader,_,_,_,'application/rdf+xml').
accept_rdf(AcceptHeader) :-
        sub_atom(AcceptHeader,_,_,_,'text/xml').
accept_rdf(_).



/**
 * Sends back towards the default representation of the resource
 * (usually html)
 */

html('http://www4.wiwiss.fu-berlin.de/rdf_browser/?browse_uri=').
reply(Request) :-
        member(path(Path),Request),
        !,
        html(Html),namespace(Namespace),
	format(atom(Redirect),'~w~w~w',[Html,Namespace,Path]),
	log:log('Sending a 303 towards ~w',Redirect),
        throw(http_reply(see_other(Redirect),[])).

port(1111).
init :- 
        port(P),
        server(P,[]),
        nl,
        writeln(' - Server launched'),nl.

:-
 nl,writeln('----------------'),nl,
 writeln(' - Launch the server on port 1111 by running ?-init.'),
 nl,writeln('----------------'),nl.


