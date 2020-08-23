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


END OF DAY 8/20
    Sort by rating
    Review functionality
    Validations
    Error handling
    Clean up search page

TODO 8/21
Sort by rating
Reviews
Clean up search page

would be nice: get google maps to work, nav-bar toggle

ToDo end of day 8/21

    edit reviews if they are yours
    fix user_favorites button on coffeeshop show
    validations
    error handling
    sort reviews by most recent


ToDo end of day 8/22
    display flash errors on validation failure
    fix remove from favorites button
    refactor for DRY and speed
    blog post, walkthrough, submit

validations:
user presence: name password email
user uniqueness: name password email
coffeeshop presences: all fields
coffeeshop uniqueness: address
user_favorite presence: user_id, coffeeshop_id
search presence: query
review presence: rating, content


TODO 8/23
    display all flash errors
    fix user_favorties button
    refactor for DRY and speed
    possibly change search back to 