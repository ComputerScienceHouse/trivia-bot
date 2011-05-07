#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use Trivia::Engine::Wikipedia::Simple;
use Trivia::Questions::Import;

my @questions = Trivia::Questions::Import::get_questions();

Trivia::Engine::Wikipedia::Simple::import(@questions);
Trivia::Engine::Wikipedia::Simple::solve();
