#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;
use Trivia::Questions::Import;
my $sock;

sub net_connect{
	my $host = "10.0.0.1";
	my $port = 4444;
	$sock = new IO::Socket::INET(
                  PeerAddr => $host,
                  PeerPort => $port,
                  Proto    => 'tcp');
	$sock or die "no socket :$!";
}

sub rx_question{
	my $id = scalar <$sock>;
	my $question = scalar <$sock>;
	my @pool;
	push(@pool, scalar <$sock>);
	push(@pool, scalar <$sock>);
	push(@pool, scalar <$sock>);
	push(@pool, scalar <$sock>);
	my %question_node = ();
	$question_node{'question'} = $question;
	$question_node{'answer_pool'} = \@pool;
	return \%question_node;
}

sub rx_answer{
	my $id = scalar <$sock>;
	my $answer = scalar <$sock>;
	#I don't care, just here for the side effects.
}

sub tx_answer{
	my %final_answer = shift;

	foreach my $key (keys(%final_answer)){
		
	}
}

sub net_disconnect{
	close $sock;
}

1;
