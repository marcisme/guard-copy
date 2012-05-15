# Guard::Copy [![Build Status](https://secure.travis-ci.org/marcisme/guard-copy.png?branch=master)](http://travis-ci.org/marcisme/guard-copy)

Copy guard copies files to one or more locations whenever files are
created or modified.

* Tested against Ruby 1.8.7, 1.9.2, 1.9.3, and the latest versions of JRuby

## Installation

Please be sure to have [Guard](https://github.com/guard/guard)
installed.

Install the gem:

    $ gem install guard-copy

Add guard definition to your Guardfile by running this command:

    $ guard init copy

## Usage

Please read [Guard usage doc](https://github.com/guard/guard#readme)

## Guardfile

Copy guard can copy files from one source directory to one or more
target directories identified either explicitly or with wildcards.

### Single Target

``` ruby
guard :copy, :from => 'source', :to => 'target'
```

### Multiple Targets

``` ruby
guard :copy, :from => 'source', :to => ['t1', 't2'] 
```

### Newest Wildcard Target

``` ruby
guard :copy, :from => 'source', :to => 'target*', :glob => :newest
```

This guard will copy files from the source directory to the newest
directory starting with 'target'.

## Author

[Marc Schwieterman](https://github.com/marcisme)

## License

Copyright (c) 2012 Marc Schwieterman

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
