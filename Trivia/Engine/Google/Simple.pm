#!/usr/bin/perl
use strict;
use warnings;
package Trivia::Engine::Google::Simple;
use REST::Google::Search;
use List::Util qw[min max];
use Lingua::EN::Tagger;

use 5.010;

REST::Google::Search->http_referer('http://google.com');
my %scores;
my @questions;

state $tagger;

sub input{
	@questions = @_;
}

sub num_results_for_query{
	my $query = shift;

        my $res = REST::Google::Search->new(
       	        q => $query,
        );

       	die "Oh dear, REST response status 200: Temp-banned from Google\n" if $res->responseStatus != 200;
        my $data = $res->responseData;

       	my $cursor = $data->cursor;
        return $cursor->estimatedResultCount;
}

#TODO add query permutations that will be helpful, using simple natural language processing
sub permutate{
	my $question = shift;
    $tagger //= Lingua::EN::Tagger->new();
    return $tagger->get_nouns($tagger->add_tags($question));
}


sub solve{
my $num_correct=0;

foreach my $question_node_ref (@questions){
	my $start_time = [Time::HiRes::gettimeofday];
	my %question_node = %$question_node_ref;

	my $question = $question_node{'question'};
	my $answer = $question_node{'answer'};
	my $answer_pool_ref = $question_node{'answer_pool'};
	my @answer_pool = @$answer_pool_ref;
	
	my $scores_ref = find_best($question, \@answer_pool);

#	print "Question: $question\n";
	%scores = %$scores_ref;
	my @keys;
	foreach my $key (sort score_hash_cmp (keys(%scores))){
		my $p = $scores{$key};
		$p = sprintf("%.4f", $p);
#		print "Answer: $key P=$p\n";
		push (@keys,$key);
	}
	my $final_answer = (sort score_hash_cmp (keys(%scores)))[0];
	my $elapsed_time = Time::HiRes::tv_interval($start_time);
	
	return $scores_ref;
}

#print "We got $num_correct of ".scalar(@questions)." questions correct.\n";
}

sub score_hash_cmp{
	$scores{$b} <=> $scores{$a};
}

sub find_best{
	my $question = shift;
	my $options_ref = shift;
	my @options = @$options_ref;

	my %results = ();

	my ($best_result,$max_results)=("",0);
	foreach my $possible_answer (@options){
		my @query_permutations = permutate($question);
		foreach my $base_query (@query_permutations){
			my $num_results = Trivia::Engine::Google::Simple::num_results_for_query($base_query.' '."\"".$possible_answer."\"");
			my $score = $num_results; #TODO make score more complicated

			if(exists($results{$possible_answer})){
				my $ref = $results{$possible_answer};
				my @res = @$ref;
				push(@res, $score);
				$results{$possible_answer} = \@res;
			}
			else{
				$results{$possible_answer} = [$score];
				
			}
		}
	}
	
	my %scored_results = ();
	my $sum_score = 0;

	foreach my $possible_answer (keys(%results)){
		my $scores_ref = $results{$possible_answer};
		my @scores = @$scores_ref;
		my $score = eval join '+', @scores; #sum
		$sum_score += $score;
		$scored_results{$possible_answer} = $score;
	}
	
	#Normalize
	my @scores;
	foreach my $possible_answer (keys(%scored_results)){
		$scored_results{$possible_answer} /= $sum_score;
	}

	return \%scored_results;
}

1;
