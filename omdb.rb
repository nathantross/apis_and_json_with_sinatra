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

class Search
    attr_accessor :title, :year, :number

    def initialize(title, year, number)
      @title = title
      @year = year
      @number = number
    end
end


post '/result' do
  search = params[:movie]
  response = Typhoeus.get "www.omdbapi.com", :params => {:s => search} 
  result = JSON.parse(response.body)

  list = []
  result["Search"].each { |movie| list << Search.new(movie["Title"], movie["Year"], movie["imdbID"]) }

  # Modify the html output so that a list of movies is provided. (includes a link to each movie's poster, based on id)
  html_str = "<html><head><title>Movie Search Results</title></head><body><h1>Movie Results</h1>\n<ul>"
  list.each { |movie| html_str += "<li><a href='/poster/#{movie.number}'>#{movie.title} - #{movie.year}</a></li>" }
  html_str += "</ul></body></html>"

end

get '/poster/:imdb' do |imdb_id|
  response = Typhoeus.get "www.omdbapi.com", :params => {:reference => imdb_id}
  result = JSON.parse(response.body)
  poster = result["Poster"]
  
  # Make another api call here to get the url of the poster.
  html_str = "<h1>Movie Poster</h1>\n"
  html_str += "<img href='#{poster}' src='#{poster}'/>"
  html_str += "<br><br>"
  html_str += '<a href="/">New Search</a></body></html>'

end