package Supervisord::Client;
use strict;
use warnings;
use LWP::Protocol::http::SocketUnixAlt;
use Data::Dumper::Concise;
use RPC::XML::Client;
use Moo::Lax;
use Carp;
use Safe::Isa;

LWP::Protocol::implementor( supervisorsocketunix => 'LWP::Protocol::http::SocketUnixAlt' );

has path_to_supervisor_config => (
    is => 'ro',
    required => 0,
);

has serverurl => (
    is => 'ro',
    required => 0,
);

has rpc => ( is => 'lazy' );

sub _build_rpc {
    my $self = shift;
    my $url = $self->serverurl;
    $url =~ s|unix://|supervisorsocketunix:|g;
    $url .= "//RPC2";
    warn $url;
    my $cli = RPC::XML::Client->new($url);
}

sub BUILD {
    my $self = shift;
    $self->path_to_supervisor_config || $self->serverurl || croak "path_to_supervisor_config or serverurl required.";
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $remote_method = $AUTOLOAD;
    $remote_method =~ s/.*:://;
    my ( $self, @args ) = @_;
    my $ret = $self->rpc->send_request( "supervisor.$remote_method", @args );
    return $ret->value if $ret->$_can("value");
}



#my $path = "file:///home/skaufman/dev/Supervisord-Client/example/supervisor.sock";
##my $resp = $cli->send_request('supervisor.getVersion');
#my $resp = $cli->send_request('supervisor.getAllProcessInfo');
#warn Dumper $resp->value;
##my $req =
##"POST /RPC2 HTTP/1.1\r\nHost: localhost\r\nAccept-Encoding: identity\r\nContent-Length: 115\r\nContent-Type: text/xml\r\nAccept: text/xml\r\nUser-Agent: xmlrpclib.py/1.0.1 (by www.pythonware.com)\r\n\r\n<?xml version='1.0'?>\n<methodCall>\n<methodName>supervisor.getVersion</methodName>\n<params>\n</params>\n</methodCall>\n";
#
1;
=head1 NAME

Supervisord::Client - a perl client for Supervisord's XMLRPC.
