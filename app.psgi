use Plack::Builder;
use Plack::App::File;
use Plack::App::Proxy;
use Plack::Middleware::Header;
use Plack::Middleware::RequestHeaders;
use Plack::Middleware::GoogleAnalytics;
	
builder { 
	mount "/"      => builder {
	  enable "Plack::Middleware::GoogleAnalytics", ga_id => 'UA-2150536-5';
	  Plack::App::File->new(file => "./static/index.html")
	};
	mount "/speak" => builder {
		enable 'RequestHeaders', unset => [ "Referer" ];
		enable 'Header', set => [
			"Content-Type" => "audio/mp3", 
			"Content-Disposition" => "attachment" 
		];

		Plack::App::Proxy->new(remote => "http://translate.google.com/translate_tts")
	}
}