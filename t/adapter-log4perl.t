#!perl
use File::Temp;
use File::Slurp;
use Log::Any;
use Log::Any::Test::InternalOnly;
use Test::More tests => 1;
use Log::Log4perl;
use strict;
use warnings;

my $dir = File::Temp->newdir();
my $conf = "
log4perl.rootLogger                = INFO, Logfile
log4perl.appender.Logfile          = Log::Log4perl::Appender::File
log4perl.appender.Logfile.filename = $dir/test.log
log4perl.appender.Logfile.layout   = Log::Log4perl::Layout::PatternLayout
log4perl.appender.Logfile.layout.ConversionPattern = %c %p %m%n
";

Log::Log4perl::init(\$conf);
Log::Any->set_adapter('Log::Log4perl');
Log::Any->get_logger(category => 'Foo')->error("hello");
Log::Any->get_logger(category => 'Bar')->info("goodbye");
Log::Any->get_logger(category => 'Baz')->debug("aigggh!");

is(read_file("$dir/test.log"), "Foo ERROR hello\nBar INFO goodbye\n", "got expected logs");
