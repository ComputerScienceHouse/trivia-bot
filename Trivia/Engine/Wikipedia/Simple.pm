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
    return join(' ', keys(%$res));
}

sub solve {
    my ($nouns, $entry, $question);

    $tagger //= Lingua::EN::Tagger->new();
    $wiki //= WWW::Wikipedia->new( language => 'en' );
    foreach my $question_ref (@questions_ref) {
        $question = $question_ref->{question};
        $nouns = _grab_nouns($question, sub { $tagger->get_proper_nouns(shift) });

        if (not $nouns) {
            $nouns = _grab_nouns($question, sub { $tagger->get_nouns(shift) });
        }

        $entry = $wiki->search($nouns);
        say $entry->title if defined $entry;
    }
}

1;
