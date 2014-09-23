require 'sinatra/base'
require 'kramdown'
require "yaml"

set :static, false

class XprogrammingHandler < Sinatra::Base

  set :markdown, :parse_block_html => true
  set :markdown, :smartypants => true

  Article = Struct.new(:icon, :category, :title, :blurb) # date?

  def getPicture(category)
    case category.downcase
    when "kate oneal"
      "kate.png"
    when "articles"
      "viewtoday.png"
    when "beyond agile"
      "katetrans.png"
    else
      "foo.png"
    end
  end

  get '/' do
    all_slugs = Dir.glob(settings.public_folder + '/articles/*')
    # TODO SORT THEM
    articles = all_slugs.collect do | slug | 
      # TODO: WHAT IF THERE IS NO FILE
      # TODO: WHAT IF THE MARKDOWN FILE DOESN'T END IN .md
      markdown_file = Dir.glob(slug + "/*.md")[0]
      # TODO: WHAT IF THERE'S NO YAML IN THE FILE
      headers = YAML.load(File.read(markdown_file))
      precis = headers["precis"] || "Read this article without having any clue what it is about."
      category = headers["category"] || "Articles"
      picture_name = getPicture(category)
      Article.new(picture_name, category, headers["title"], markdown(precis) )
    end
    (0..20).each do |i|
      articles << Article.new("kate.png", "Articles", "Dummy Article #{i}", "Dummy Precis which has now been made about as long as the other <br><br><br><br>")
    end
    @favorites = articles[0..2]
    @the_rest = articles[3..-1]
    erb :frontpage
  end

  get '/image/:img' do
    send_file File.join('public/articles/xprog-layout/', params[:img]), :type => 'image/jpeg', :disposition => 'inline'
  end
end
