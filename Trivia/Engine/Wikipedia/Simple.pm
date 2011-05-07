package Trivia::Engine::Wikipedia::Simple;

use strict;
use warnings;
use 5.010;

use Data::Dumper;
use Lingua::EN::Tagger;
use WWW::Wikipedia;

my @questions_ref;
state ($tagger, $wiki);

sub import {
    @questions_ref = @_;
}

# Returns a hashref of all of the nouns in a question
sub _grab_nouns {
    my ($question, $func) = @_;
    my $res = { $func->($tagger->add_tags($question)) };
    join(' ', keys(%$res))
}

sub is_bob {
    my $question = shift;
    $question =~ /\bnot\b/
}

sub solve {
    my ($nouns, $entry, $question, $score_ref);

    $tagger //= Lingua::EN::Tagger->new();
    $wiki //= WWW::Wikipedia->new( language => 'en' );
    foreach my $question_ref (@questions_ref) {
        $question = $question_ref->{question};
        $nouns = _grab_nouns($question, sub { $tagger->get_proper_nouns(shift) });

        if (not $nouns) {
            $nouns = _grab_nouns($question, sub { $tagger->get_nouns(shift) });
        }

        $entry = $wiki->search($nouns);
        return undef if not $entry;
        return $score_ref = _calc_results($entry, $question_ref);
    }
}

sub _calc_results {
    my ($entry, $question_ref) = @_;
    my ($num, @res, $score_ref, $total);
    $score_ref = {};
    $total = 0;
    
    foreach my $answer (@{$question_ref->{answer_pool}}) {
        chomp $answer;

        @res = $entry->text =~ /$answer/gm;
        $num = @res;

        $score_ref->{$answer} = $num;
        $total += $num;
    }

    map { $score_ref->{$_} = ( $score_ref->{$_} / $total ) } keys %$score_ref if $total != 0;

    return $score_ref;
}

1;
