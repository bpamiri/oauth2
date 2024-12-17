/**
* @displayname duo
* @output false
* @hint The duo object.
* @author Peter Amiri
* @website https://www.monkehworks.com
* @purpose A ColdFusion Component to manage authentication to DUO using the OAuth2 protocol as OIDC. Setup a OIDC application in DUO to use this module.
**/
component extends="oauth2" accessors="true" {

	property name="client_id" type="string";
	property name="client_secret" type="string";
	property name="authEndpoint" type="string";
	property name="accessTokenEndpoint" type="string";
	property name="userInfoEndpoint" type="string";
	property name="redirect_uri" type="string";
  property name="PKCE" type="struct";

	/**
	* I return an initialized duo object instance.
	* @client_id The client ID for your application.
	* @client_secret The client secret for your application.
	* @authEndpoint The URL endpoint that handles the authorisation.
	* @accessTokenEndpoint The URL endpoint that handles retrieving the access token.
	* @redirect_uri The URL to redirect the user back to following authentication.
	**/
	public duo function init(
		required string client_id,
		required string client_secret,
		required string authEndpoint,
		required string accessTokenEndpoint,
    required string userInfoEndpoint,
		required string redirect_uri
	)
	{
		super.init(
			client_id           = arguments.client_id,
			client_secret       = arguments.client_secret,
			authEndpoint        = arguments.authEndpoint,
			accessTokenEndpoint = arguments.accessTokenEndpoint,
			redirect_uri        = arguments.redirect_uri
		);
    setUserInfoEndpoint( arguments.userInfoEndpoint );
		return this;
	}

	/**
	* I return the URL as a string which we use to redirect the user for authentication.
	* @scope An list of values to pass through for scope access. DUO requires scope to be defined
	**/
	public string function buildRedirectToAuthURL(
		string scope = ''
	){
		var sParams = {};

		if( listLen( arguments.scope, ' ' ) ){
			structInsert( sParams, 'scope', arguments.scope );
		}
		return super.buildRedirectToAuthURL( sParams );
	}


	/**
	* I make the HTTP request to obtain the access token.
	* @code The code returned from the authentication request.
	**/
	public struct function makeAccessTokenRequest(
		required string code
	){
		var aFormFields = [];
		return super.makeAccessTokenRequest(
			code       = arguments.code,
			formfields = aFormFields
		);
	}

  /**
	* I make the HTTP request to get the user Info.
	* @access_token As returned with the most recent access token.
	* duo requires:
	* header:  Authorization: "Bearer " + access_token)
	**/
	public struct function makeUserInfoRequest(
		required string access_token
	){
		var stuResponse = {};
	    var httpService = new http();
	    httpService.setMethod( "get" );
	    httpService.setCharset( "utf-8" );
	    httpService.setUrl( getUserInfoEndpoint() );
	    httpService.addParam( type="header", name="Authorization", value="Bearer #arguments.access_token#" );

	    var result = httpService.send().getPrefix();
	    if( '200' == result.ResponseHeader[ 'Status_Code' ] ) {
	    	stuResponse.success = true;
	    	stuResponse.content = result.FileContent;
	    } else {
	    	stuResponse.success = false;
	    	stuResponse.content = result.Statuscode;
	    }
    	return stuResponse;
	}

}
