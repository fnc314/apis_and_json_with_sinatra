require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'

get '/' do
  html = %q(
  <html><head><title>Movie Search</title></head><body>
  <h1>Find a Movie!</h1>
  <form accept-charset="UTF-8" action="/result" method="post">
    <label for="movie">Search for:</label>
    <input id="movie" name="movie" type="text" />
    <input name="commit" type="submit" value="Search" /> 
  </form></body></html>
  )
end

post '/result' do
  search_str = params[:movie]
  request = Typhoeus.get("www.omdbapi.com", :params => {:s => search_str})
  movies = JSON.parse(request.body)["Search"].sort_by { |x| x["Year"]}.reverse
  # Make a request to the omdb api here!

  # Modify the html output so that a list of movies is provided.
  html_str = "<html><head><title>Movie Search Results</title></head><body><h1>Movie Results</h1>\n<ul>"
  if movies.nil?
    html_str += "NO FUCKING MOVIE BITCH!!!!"
  else
  movies.each do |x|

    html_str += "<li><a href=/poster/#{x["imdbID"]}>#{x['Title']}, #{x['Year']}</a></li>"
  
  end
  end


  html_str += "</ul><br><a href='/'>New Search</a></body></html>"

end

get '/poster/:imdb' do |imdb_id|
  
  request = Typhoeus.get("www.omdbapi.com", :params => {:i => imdb_id})
  id = JSON.parse(request.body)
  # Make another api call here to get the url of the poster.
  html_str = "<html><head><title>Movie Poster</title></head><body><h1>Movie Poster</h1>\n"
  html_str += "<h3>#{id["Title"]}, #{id["Year"]}</h3>"
  html_str += "<img src=#{id["Poster"]} alt='http://4.bp.blogspot.com/-XxZPs7WSmKo/UVW1O0B3UxI/AAAAAAAAAgg/Xy-6cXsr9gU/s1600/Middle-finger-emoticon.png'></img>"
  html_str += '<br /><a href="/">New Search</a></body></html>'

end

