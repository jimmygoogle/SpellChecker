## RESTful spell-checking service built with Dancer.

The API will accept a GET (check the spelling of a supplied word) or a POST (add a new word). Requests to check the spelling of a word will return a true or false status based on the spelling of the word. Incorrectly spelled words will also reutrn a suggested list properly spelled words.

When adding words, the status is determined by the error status of the speller object. This should be improved in future versions.

The responses returned:
<table>
    <tr>
    		<td>Key</td><td>Definition</td>
    </tr>
    <tr>
        <td>httpResponseCode</td><td>HTTP response code</td>
    </tr>
    <tr>
        <td>errors</td><td>Errors from the speller object  </td>
    </tr>
    <tr>
    		<td>currentApiVersion</td><td>The current version of the API</td>
    </tr>
    <tr>
        <td>suggestions</td><td>An array reference of suggested words based on the misspelled word</td>
    </tr>
    <tr>
        <td>message</td><td>A message related to the API call</td>
    </tr>
    <tr>
        <td>status</td><td>The status of the API call </td>
    </tr>
</table>

See 'TESTING' section below for examples.

## INSTALLATION
## Step 1. Install the Text::Aspell perl module:

cd /tmp  
wget ftp://ftp.gnu.org/gnu/aspell/aspell-0.60.6.1.tar.gz  
tar xf aspell-0.60.6.1.tar.gz  
cd aspell-0.60.6.1  
./configure  
make  
make install  

## Step 2. Install dictionary
cd /tmp  
wget ftp://ftp.gnu.org/gnu/aspell/dict/en/aspell6-en-7.1-0.tar.bz2   
tar xjf aspell6-en-7.1-0.tar.bz2  
cd aspell6-en-7.1-0  
./configure  
make  
make install  
get -O - http://cpanmin.us | perl - Text::Aspell  

## Step 3. Install Dancer perl module
wget -O - http://cpanmin.us | perl - Dancer

## Step 4. Run Dancer app
perl SpellChecker/bin/app.pl --port=3026

## TESTING
'localhost' can be substituted with 'jimandmeg.com' for a working non local version
## Correctly spelled word using GET
curl -i -X GET -H "Content-Type: application/json" http://localhost:3026/words/apple

## Incorrectly spelled word using GET
curl -i -X GET -H "Content-Type: application/json" http://localhost:3026/words/dogg

## Add a word with POST
curl -i -X POST -H "Content-Type: application/json" -d '{"word":"timmay"}' http://localhost:3026/words/
