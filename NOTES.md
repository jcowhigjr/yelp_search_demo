TODO EVENING 8/18:

    -Authentication
    -OAuthGoogle
    -Registration, Login, Landing styled  
    
    
    response = RestClient::Request.execute(
    method: "GET",
    url: "https://api.yelp.com/v3/businesses/search?term=coffee}&location=milwaukee",  
    headers: { Authorization: "Bearer #{ENV["YELP_API_KEY"]}" }  
    )  

TODO 8/19:

    Authentication
    OAuthGoogle

TODO 8/20:
    Add coffeeshop to favorites
    Coffeeshop show page
    User show page

TODO 8/21:
    Reviews
    Error handling
    Full functionality test

TODO 8/22:
    Finish styling
    Record walkthrough
    Write blog post
    DRY check
    Submit


REAL TODO 8/20
    OAuthGoogle
    validations
    Add Coffeeshop to favorites
    Display coffeeshops in order by rating
    Coffeeshop show page
    User Show page
    Review functionality

