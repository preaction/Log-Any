requires "B" => "0";
requires "Carp" => "0";
requires "Data::Dumper" => "0";
requires "Exporter" => "0";
requires "IO::File" => "0";
requires "Test::Builder" => "0";
requires "base" => "0";
requires "perl" => "5.008001";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "File::Spec::Functions" => "0";
  requires "File::Temp" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "List::Util" => "0";
  requires "Test::More" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.17";
};

on 'develop' => sub {
  requires "Test::CPAN::Meta" => "0";
  requires "Test::Pod" => "1.41";
};
