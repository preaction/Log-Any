use inc::Module::Install;

name 'Log-Any';
abstract 'Log anywhere';
all_from 'lib/Log/Any.pm';
author 'Jonathan Swartz <swartz@pobox.com>';

perl_version '5.006';

build_requires 'Test::Class' => 0;
build_requires 'Test::Most'  => 0;

license 'perl';

auto_install;

WriteAll;
