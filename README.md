# projects-at

* Search more than one term at once
* Add authors to projects
* Add icon / image uploading support

## Installation

This is a [Sinatra app](http://www.sinatrarb.com/), which is incidentally a pretty
cool little web framework. It might be helpful to install the [Thin](http://code.macournoyer.com/thin/)
webserver. 

Currently the following gem dependencies are located in the .gems file. You can
install them from scratch by using the command:
    
    cat .gems | xargs sudo gem install
    
Alternatively, you can install them to the root/.gem directory by calling the command

    script/unpack
    
Then, you need to move a `config.yaml.template` to `config.yaml` and add a password
to the db parameters.
  
## License
MIT-licensed

    Copyright (c) 2010 Bryan Summersett
    
    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following
    conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.
 
