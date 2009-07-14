use inc::Module::Install;

name 'Log-Any';
abstract 'Log anywhere';
all_from 'lib/Log/Any.pm';
author 'Jonathan Swartz <swartz@pobox.com>';

perl_version '5.006';

build_requires 'Test::More' => 0;

requires 'Carp' => 0;

license 'perl';

auto_install;

WriteAll;
