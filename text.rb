require 'erb'

def load(database)
  graphs = []

  open(database).each do |line|
    name, data = line.gsub('(', '|[').gsub(')', ']').split('|')
    data = eval(data)

    nodes = {}
    data[3].each_with_index {|c, i| nodes["#{i+1}"] = c.join(',')}

    graphs << {
      :name => name, :n => data[0], :m => data[1],
      :degrees => data[2].map {|x, y| [x] * y}.flatten,
      :nodes => nodes, :edges => data[4],
    }
  end

  graphs
end

def create_template(filename); ERB.new(open(filename).read); end

GRAPHS = load('database.gdb')
GRAPHVIZ = create_template('graph.dot.erb')
INDEX = create_template('index.html.erb')
GRAPH_PAGE = create_template('graph.html.erb')
INDEX_L = create_template('index-l.html.erb')
GRAPH_PAGE_L = create_template('graph-l.html.erb')

open('public/index.html', 'w').puts(INDEX.result)
open('public/index-l.html', 'w').puts(INDEX_L.result)

GRAPHS.each do |graph|
  g = graph

  open("dot/#{g[:name]}.dot", 'w').
    puts(GRAPHVIZ.result(binding))

  open("public/#{g[:name]}.html", 'w').
    puts(GRAPH_PAGE.result(binding))

  open("public/#{g[:name]}-l.html", 'w').
    puts(GRAPH_PAGE_L.result(binding))
end