use Plack::Builder;
use Plack::App::File;
use Plack::App::Directory;
use Plack::App::Proxy;
use Plack::Middleware::Header;
use Plack::Middleware::RequestHeaders;
	
builder { 
	mount "/"        => Plack::App::File->new(file => "./static/index.html");
	mount "/static/" => Plack::App::Directory->new(root => "./static/");
	mount "/speak"   => builder {
		enable 'RequestHeaders', unset => [ "Referer" ];
		enable 'Header', set => [
			"Content-Type" => "audio/mp3", 
			"Content-Disposition" => "attachment; filename=speak-bro.mp3" 
		];

		Plack::App::Proxy->new(remote => "http://translate.google.com/translate_tts")
	}
}
