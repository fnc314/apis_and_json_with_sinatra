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
  movies = JSON.parse(request.body)["Search"]
  html_str = "<html><head><title>Movie Search Results</title></head><body><h1>Movie Results</h1>\n<ul>"
  if movies.nil?
    html_str += "<img src='http://gifs.gifbin.com/092009/reverse-1253886001_office-no.gif'></img><br><h6>NO POSTER</h6>"
  else
  movies = JSON.parse(request.body)["Search"].sort_by { |x| x["Year"]}.reverse
  movies.each do |x|

    html_str += "<li><a href=/poster/#{x["imdbID"]}>#{x['Title']}, #{x['Year']}</a></li>"
  end
  
  end

  html_str += "</ul><br><a href='/'>New Search</a></body></html>"
end

get '/poster/:imdb' do |imdb_id|
  request = Typhoeus.get("www.omdbapi.com", :params => {:i => imdb_id})
  id = JSON.parse(request.body)
  html_str = "<html><head><title>Movie Poster</title></head><body><h1>Movie Poster</h1>\n"
  html_str += "<h3>#{id["Title"]}, #{id["Year"]}</h3>"
  html_str += "<object data=#{id["Poster"]}><img src='http://speckycdn.sdm.netdna-cdn.com/wp-content/uploads/2010/03/four-oh-four_25.jpg'></img></object>"
  html_str += '<br /><a href="/">New Search</a></body></html>'
end

#try a search for something random that wouldn't have a poster.