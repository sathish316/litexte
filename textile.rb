class TextileParser
  def initialize 
  end
  
  def parse(input)
    input.gsub!(/(.*?)\n\n/,'<p>\1</p>')
    input.gsub!(/h1\.(.*?)\n/,'<h1>\1</h1>')
    input.gsub!(/h2\.(.*?)\n/,'<h2>\1</h2>')
    input.gsub!(/h3\.(.*?)\n/,'<h3>\1</h3>')
    input.gsub!(/bq\.(.*?)\n/,'<blockquote>\1</blockquote>')
    input.gsub!(/\[(\d+)\]/,'<sup><a href="#fn\1">\1</a></sup>')
    input.gsub!(/fn(\d+)\./,'<sup>\1</sup>')
    
    input.gsub!(/\_{2}(.*?)\_{2}/,'<i>\1</i>')
    input.gsub!(/\*{2}(.*?)\*{2}/,'<b>\1</b>')    
    input.gsub!(/\?{2}(.*?)\?{2}/,'<cite>\1</cite>')    
    input.gsub!(/\_{1}(.*?)\_{1}/,'<em>\1</em>')
    input.gsub!(/\*{1}(.*?)\*{1}/,'<strong>\1</strong>')
    input.gsub!(/\@{1}(.*?)\@{1}/m,'<code>\1</code>')
    input.gsub!(/\-{1}(.*?)\-{1}/,'<del>\1</del>')
    input.gsub!(/\+{1}(.*?)\+{1}/,'<ins>\1</ins>')
    input.gsub!(/\^{1}(.*?)\^{1}/,'<sup>\1</sup>')
    input.gsub!(/\~{1}(.*?)\~{1}/,'<sub>\1</sub>')
    input.gsub!(/\%{1}(\{(.*)\})?(.*?)\%{1}/m) do
      style = $1 ? " style=\"#{$2}\" " : ''
      "<span#{style}>#{$3}</span>"
    end
    input.gsub!(/p(\((.*)\))?(\{(.*)\})?(\[(.*)\])?\.(.*?)\n/) do
      id_or_class = $2
      style = $4 ? " style=\"#{$4}\"" : ""
      lang = $6 ? " lang=\"#{$6}\"" : ""
      text = $7
      mdata = $2 ? $2.match(/(\w+)?#?(\w+)?/) : []
      _class = $1 ? " class=\"#{$1}\"" : ""
      _id = $2 ? " id=\"#{$2}\"" : ""
      "<p#{_id}#{_class}#{style}#{lang}>#{text}</p>"
    end
    input
  end
end

parser = TextileParser.new
puts parser.parse(File.open(ARGV[0]).readlines.join)
