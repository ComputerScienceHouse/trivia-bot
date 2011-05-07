#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw (time);
#use Trivia::Lingua;

use Trivia::Questions::Import;
use Trivia::Engine::Google::Simple;
use Trivia::Engine::Google::Exact;
use Trivia::Engine::Wikipedia::Simple;

use Data::Dumper;

my @questions=Trivia::Questions::Import::get_questions();
my %final_answer = ();

my $num_correct=0;
foreach my $question (@questions){
	my %question_node = %$question;
	my $answer = $question_node{'answer'};
	my $question_text = $question_node{'question'};

	#COMPUTE TIME
	Trivia::Engine::Google::Simple::input($question);
	Trivia::Engine::Google::Exact::input($question);
	my $google_simple_scores = Trivia::Engine::Google::Simple::solve();
	my $google_exact_scores = Trivia::Engine::Google::Exact::solve();
	#my $wiki_simple_scores = Trivia::Engine::Wikipedia::Simple::solve();
	#print Dumper($wiki_simple_scores);
	%final_answer = ();

	print "Question was: $question_text\n";
	foreach my $key (keys(%$google_simple_scores)){
		$final_answer{$key} = $google_simple_scores->{$key}*0.4 + $google_exact_scores->{$key}*0.6;
		my $google_simple_score = $google_simple_scores->{$key};
		my $google_exact_score = $google_exact_scores->{$key};
	#	my $wiki_simple_score = $wiki_simple_scores->{$key};
		$google_simple_score = sprintf("%.4f", $google_simple_score);
		$google_exact_score = sprintf("%.4f", $google_exact_score);
		my $final_score = sprintf("%.4f", $final_answer{$key});
	#	$wiki_simple_score = sprintf("%.4f", $wiki_simple_score);
		print "A=$key GS=$google_simple_score GE=$google_exact_score FS=$final_score\n";
	}
		
	my $final_answer = (sort score_hash_cmp (keys(%final_answer)))[0];

	print "My guess is: $final_answer\n";
	print "Actual answer was: $answer\n";
	if( $final_answer eq $answer){
		print "CORRECT!\n";
		++$num_correct;
	}
	else{
		print "WRONG.\n";
	}
	sleep(2);
}

print "We got $num_correct of ".scalar(@questions)." questions correct.\n";

sub score_hash_cmp{
	$final_answer{$b} <=> $final_answer{$a};
}
