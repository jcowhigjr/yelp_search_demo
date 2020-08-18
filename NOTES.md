TODO EVENING 8/18:

    -Authentication
    -OAuthGoogle
    -Registration, Login, Landing styled  
    
    
    response = RestClient::Request.execute(
    method: "GET",
    url: "https://api.yelp.com/v3/businesses/search?term=coffee}&location=milwaukee",  
    headers: { Authorization: "Bearer #{ENV["YELP_API_KEY"]}" }  
    )  