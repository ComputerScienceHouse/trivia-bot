#!/usr/bin/perl
use strict;
use warnings;
use Trivia::Questions::Import;
use Data::Dumper;

my @questions=Trivia::Questions::Import::get_questions();

foreach my $question (@questions){
	my %question_node = %$question;
	my $question_text = $question_node{'question'};
	my $answer = $question_node{'answer'};
	my @questions = $question_node{'answer_pool'};
	my @filtered_questions = ();

	#filter out correct
	foreach my $question (@questions){
	
		foreach my $s (@$question){
			unless($s eq $answer){;
				push (@filtered_questions, $s);
			}
		}
	}
	
	#print for thomas
	print $question_text."\n";
	foreach my $q (@filtered_questions){
		print $q."\n";
	}
	print $answer."\n";
}
