use inc::Module::Install;

name 'Log-Any';
abstract 'Log anywhere';
all_from 'lib/Log/Any.pm';
author 'Jonathan Swartz <swartz@pobox.com>';

build_requires 'Test::Simple' => 0;

license 'perl';

auto_install;

WriteAll;
