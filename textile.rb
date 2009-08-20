class TextileParser  
  def parse(input)
    # lists
    input = gsub_lists(input, '#')
    input = gsub_lists(input, '*')
    # tables
    input = gsub_tables(input)
    # a
    input.gsub!(/"(\w+)":(\S+)/,'<a href="\2">\1</a>')
    # misc
    input.gsub!(/(.*?)\n\n/,'<p>\1</p>')
    input.gsub!(/\[(\d+)\]/,'<sup><a href="#fn\1">\1</a></sup>')
    input.gsub!(/fn(\d+)\./,'<sup>\1</sup>')
    input.gsub!(/\!{1}(.*?)\!{1}/,'<img src="\1"/>')
    input.gsub!(/\@{1}(.*?)\@{1}/m,'<code>\1</code>')
    # start marker
    input.gsub!(/h1\.(.*?)\n/,'<h1>\1</h1>')
    input.gsub!(/h2\.(.*?)\n/,'<h2>\1</h2>')
    input.gsub!(/h3\.(.*?)\n/,'<h3>\1</h3>')
    input.gsub!(/bq\.(.*?)\n/,'<blockquote>\1</blockquote>')
    # delimiter
    input.gsub!(/\_{2}(.*?)\_{2}/,'<i>\1</i>')
    input.gsub!(/\*{2}(.*?)\*{2}/,'<b>\1</b>')    
    input.gsub!(/\?{2}(.*?)\?{2}/,'<cite>\1</cite>')    
    input.gsub!(/\_{1}(.*?)\_{1}/,'<em>\1</em>')
    input.gsub!(/\*{1}(.+?)\*{1}/,'<strong>\1</strong>')
    input.gsub!(/\-{1}(.*?)\-{1}/,'<del>\1</del>')
    input.gsub!(/\+{1}(.*?)\+{1}/,'<ins>\1</ins>')
    input.gsub!(/\^{1}(.*?)\^{1}/,'<sup>\1</sup>')
    input.gsub!(/\~{1}(.*?)\~{1}/,'<sub>\1</sub>')
    # span
    input.gsub!(/\%{1}(\{(.*)\})?(.*?)\%{1}/m) do
      style = $1 ? " style=\"#{$2}\" " : ''
      "<span#{style}>#{$3}</span>"
    end
    # p
    input.gsub!(/p([\<\>\=]+)?(\((.*)\))?(\{(.*)\})?(\[(.*)\])?\.(.*?)\n/) do
      aligns = {'<' => 'left', '>' => 'right', '=' => 'center', '<>' => 'justify'}
      align = $1 ? " text-align: #{aligns[$1]};" : ""
      styles = $5 || ""
      style = (align + styles).empty? ? "" : " style=\"#{align}#{styles}\""
      lang = $7 ? " lang=\"#{$7}\"" : ""
      text = $8
      mdata = $3 ? $3.match(/(\w+)?#?(\w+)?/) : []
      _class = mdata[1] ? " class=\"#{mdata[1]}\"" : ""
      _id = mdata[2] ? " id=\"#{mdata[2]}\"" : ""
      "<p#{_id}#{_class}#{style}#{lang}>#{text}</p>"
    end
    input
  end
  
  def gsub_lists(input, symbol = '#')
    list = ""
    new_input = ""
    pattern = symbol == '#' ? /^#/ : /^\*/
    input.split("\n").each do |line|
      if line =~ pattern
        list += line + "\n"
      else
        new_input += parse_list(list,symbol) unless list.empty?
        new_input += line + "\n"
        list = ""
      end
    end
    new_input
  end
  
  def parse_list(list, symbol = '#')
    item_pattern = symbol == '#' ? /^#+.*?\n/ : /^\*+.*?\n/
    item_splitter = symbol == '#' ? /(#+)(.*)/ : /(\*+)(.*)/
    items = list.scan(item_pattern).map(&:chomp).collect {|item| item =~ item_splitter; [$1,$2]}
    parse_list_items(items, symbol) 
  end
  
  def parse_list_items(items, symbol = '#', start = 0)
    list_out = symbol == '#' ? "<ol>" : "<ul>"
    i = 0
    while(i < items.length)
      level, item = items[i]
      if level.length-start == 1
        list_out += "<li>#{item}</li>"
        i += 1
      else
        j = i + (items[i,items.size].find_index {|e| e[0].length == start+1} || items.length)
        list_out += parse_list_items(items[i,j-1], symbol, start+1)
        i += (j-1)
      end
    end
    list_out += symbol == '#' ? "</ol>" : "</ul>"
  end
  
  def gsub_tables(input)
    table = ""
    new_input = ""
    input.split("\n").each do |line|
      if line =~ /^\|/
        table += line + "\n"
      else
        new_input += parse_table(table) unless table.empty?
        new_input += line + "\n"
        table = ""
      end
    end
    new_input
  end
  
  def parse_table(table)
    header = /^\_\./
    out = "<table>"
      table.each do |row|
        out += "<tr>"
        row.split('|').reject {|t| t.chomp.empty?}.each do |cell|
          if cell =~ header
            out += "<th>#{cell.sub(header,'')}</th>"
          else
            out += "<td>#{cell}</td>"
          end
        end
        out += "</tr>"
      end
    out += "</table>"
  end
end

parser = TextileParser.new
puts parser.parse(File.open(ARGV[0]).readlines.join)
