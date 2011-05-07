#!/usr/bin/perl
use strict;
use warnings;
package Trivia::Engine::Wikipedia::Simple;
use WWW::Wikipedia;
use Data::Dumper;
use List::Util qw[min max];
my $wiki = WWW::Wikipedia->new();

my %scores;
my @questions;

sub input{
	@questions = @_;
}

sub num_results_for_query{
	my $final_ret = 0;

	my $base_query = shift;
	my $possible_answer = shift;

        my $result = $wiki ->search($base_query);

	#Deal with redirects
	if ($result -> text() =~ m/#redirect/){
		my $newquery = $result-> text();
		$newquery =~ s/#redirect//;
		$result = $wiki->search($newquery);
	}
	if ( $result -> text() ) {
		if($result-> text() =~ m/$possible_answer/){
			$final_ret=1;
		}
	}

        return $final_ret;
}

#TODO add query permutations that will be helpful, using simple natural language processing
sub permutate{
	my $question = shift;
	my $parser = new Lingua::LinkParser;
	my $parsed_question = $parser->create_sentence($question);
	my $question_linkage = $parsed_question->linkage(1);
	
	print $parser->get_diagram($question_linkage);
	 
	return $question;
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
	print "W:S Elapsed time: $elapsed_time seconds.\n\n";

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
			my $num_results = Trivia::Engine::Wikipedia::Simple::num_results_for_query($base_query,$possible_answer);
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
	

	return \%scored_results;
}

1;
