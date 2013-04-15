## Speak, bro

This is a small psgi application, inspired in [falai-fera](https://github.com/danielfm/falai-fera), who transform a small text (less than 100 characters) in mp3 using google translate. It is pure-perl plack configuration.

## Install

You need install Plack and other dependencies, for example using [carton](https://metacpan.org/module/Carton) (based on cpanfile)

	bash$ carton install

or, using [cpanminus](https://metacpan.org/module/App::cpanminus)

	bash$ cpanm -L local --installdeps .
	
or, install manually all deps using regular cpan

* Plack
* Plack::App::Proxy
* Plack::Middleware::Header
* Plack::Middleware::RequestHeaders
	
## Running	

You can use plackup or other psgi server like Starman

	bash$ plackup app.psgi
	
## How it works

This app has two components: one static file (index.html) and one psgi file, who combine two apps and two middlewares. 

	├── cpanfile
	├── app.psgi
	└── static
	    └── index.html

this is the relevant html (just a form to /speak with a hidden input `tl` and a textarea `q`)

	<form id="myform" action="/speak">
		<input type="hidden" name="tl" value="en"/>
		<textarea name="q" rows="2" cols="100" maxlength="100" class="required">I should have know better than to let you go alone.
	It's times like these I can't make it on my own</textarea><br/>
		<input type="submit" name="submit" value="Give me the .mp3!"/>
	</form>


this is the psgi file using [plack builder dsl](https://metacpan.org/module/Plack::Builder):

	builder { 
		mount "/"      => Plack::App::File->new(file => "./static/index.html");
		mount "/speak" => builder {
			enable 'RequestHeaders', unset => [ "Referer" ];
			enable 'Header', set => [
				"Content-Type" => "audio/mp3", 
				"Content-Disposition" => "attachment" 
			];

			Plack::App::Proxy->new(remote => "http://translate.google.com/translate_tts")
		}
	}
	
the `builder` subroutine create a [plack](https://metacpan.org/release/Plack) application. In this case we combine two applications in different paths using the `mount` subroutine. The first path is "/" and we use [Plack::App::File](https://metacpan.org/module/Plack::App::File) to serve the index.html (this application is part of Plack implementation). The second path, "/speak", use another application, [Plack::App::Proxy](https://metacpan.org/module/Plack::App::Proxy), to receive the request submit from index.html and proxy to google translate text to speech experimental api. The google api hates requests from other sites and returns a 403, but using [Plack::Middleware::RequestHeaders](https://metacpan.org/module/Plack::Middleware::RequestHeaders) we can remove the `Referer` header. In the end, we use the [Plack::Middleware::Header](https://metacpan.org/module/Plack::Middleware::Header) middleware to set two headers: `Content-Disposition` to act as a download and `Content-Type` to add a .mp3 extension.

## Deploy

### Heroku 

You can follow this instructions: [Heroku buildpack perl](https://github.com/miyagawa/heroku-buildpack-perl).

Try [here](http://ancient-plateau-6546.herokuapp.com/). Thanks L0rn!

## Final considerations

This is a good example of using Plack applications and middlewares. It is easy to evolve and add other features and it is zero code, I'm just using a dsl to compose and configure other apps (all available in CPAN).
