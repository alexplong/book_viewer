require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs (chapter)
    chapter.split("\n\n").map.with_index do |paragraph, index|
      "<div id='<%= index %>'><p>#{paragraph}</p></div>"
    end.join
  end
end

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    results << { number: number, name: name , paragraph: paragraphs_matching(contents, query)} if contents.include?(query)
  end

  results
end

def paragraphs_matching(query_string, query)
  query_string.split("\n\n").select do |paragraph|
    paragraph.include?(query)
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmeys"
  erb :home
end

get "/chapters/:number" do
  number = params["number"]
  chapter_name = @contents[number.to_i - 1]
  @title = "Chapter #{number}: #{chapter_name}"
  
  @chapter = File.read("data/chp#{number}.txt")
  puts @chapter.split "\n"
  erb :chapter
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

not_found do
  redirect "/"
end