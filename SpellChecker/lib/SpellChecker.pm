package SpellChecker;

use Dancer ':syntax';
use Dancer::Response;
use Text::Aspell;

our $VERSION = '0.1';

set serializer => 'JSON';

get '/words' => sub 
{ 
	my $responseObject = Dancer::SharedData->response;

	my $returnResponse = _returnResponse(
	{
		'status'            => 'false',
		'httpResponseCode'  => $responseObject->status,
		'errors'            => 'Please supply a word to be spell checked.',		
	});
	
	return($returnResponse);
};

get '/words/:word' => sub 
{ 
	my $params = request->params;
		
	return( _isWordSpelledCorrectly($params) );
};

post '/words/' => sub 
{ 
	my $params = request->params;
	
	return( _addWordToDictionary($params) );
};

sub _returnResponse
{
	my ($params) = @_;
	
	my $returnResponse = 
	{
		'httpResponseCode'  => $params->{'httpResponseCode'}    || '',
		'errors'            => $params->{'errors'}              || '',
		'currentApiVersion' => $VERSION,
		'data' => 
		{
			'suggestions'   => $params->{'suggestions'}     || [],	
			'message'       => $params->{'message'}         || '',	
			'status'        => $params->{'status'}          || 'unknown',
		}	
	};
	
	return([$returnResponse]);
}

sub _isWordSpelledCorrectly
{
	my ($params) = @_;
	
	my $spellerObject  = _createrSpellerObject();
	my $responseObject = Dancer::SharedData->response;
	
	my $status = 'false';
	my @suggestionsList;
	my $isSpelled;
		
	## word is spelled correctly
	if(
		($spellerObject->check( $params->{'word'} )) 
		&& 
		(!$spellerObject->errstr)
	)
	{
		$status = 'true';
		
		## used in return message
		$isSpelled = 'correctly';
	}
	    
	## word was not spelled right so offer suggestions
	## make sure there is no errors too
	elsif(!$spellerObject->errstr)
	{	
		## find suggestions to word	
		my @suggestions = $spellerObject->suggest( $params->{'word'} );
		
		## only return X number of suggestions
		## since there is no need to output the entire bank
		my $maxSuggestedCount = ($ENV{'MAX_SUGGESTED_WORDS'} || 10) - 1;
		
		## handle the conditions where the suggest list is less than the default
		if((scalar(@suggestions) - 1) < $maxSuggestedCount)
		{
			$maxSuggestedCount = scalar(@suggestions) - 1;
		}
		
		@suggestionsList = @suggestions[0..$maxSuggestedCount];
		
		## used in return message
		$isSpelled = 'incorrectly';
	}	

	my $returnResponse = _returnResponse(
	{
		'status'            => $status,
		'httpResponseCode'  => $responseObject->status,
		'errors'            => $spellerObject->errstr || '',	
		'suggestions'       => \@suggestionsList,
		'message'           => qq|$params->{'word'} is spelled $isSpelled.|,		
	});
	
	return($returnResponse);
}

sub _addWordToDictionary
{
	my ($params) = @_;
	
	my $spellerObject  = _createrSpellerObject();
	my $responseObject = Dancer::SharedData->response;

	$spellerObject->add_to_personal($params->{'word'});
	$spellerObject->save_all_word_lists();
	
	my $status = 'true';
	
	if($spellerObject->errstr)
	{
		$status = 'false';
	}	
	
	my $returnResponse = _returnResponse(
	{
		'status'            => $status,
		'httpResponseCode'  => $responseObject->status,
		'errors'            => $spellerObject->errstr || '',	
		'message'           => qq|Added the word '$params->{'word'}'|,		
	});
	
	return($returnResponse);	
}

sub _createrSpellerObject
{
	my $spellerObject = Text::Aspell->new;
	
	$spellerObject->set_option('lang','en_US');
	$spellerObject->set_option('sug-mode','fast');

	## TODO: handle case sensitve searches more intelligently
	$spellerObject->set_option('ignore-case','true');
        
	return($spellerObject);
}

true;

