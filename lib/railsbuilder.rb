#!/usr/bin/env ruby

# file: railsbuilder.rb

require 'fileutils'
require 'io/console'
require 'lineparser'


class RailsBuilder

  def initialize(filepath=nil)

    buffer = File.read filepath if filepath

    patterns = [
      [:root, 'app: :app', :app],
      [:root, 'resources: :resources', :resources],
      [:root, ':resource', :resource],
        [:resource, 'model', :model],
          [:model, ':class_name', :model_class],
      [:all, /#/]
    ]

    @h = parse(patterns, buffer)
  end

  def build()

    cols = @h[:root].select {|x| x[1].has_key? ':app' }
    @app = cols[0][1][':app']

    unless File.exists? @app then
      command = 'rails new ' + @app
      puts ":: preparing to execute shell command: `#{command}`"
      puts 'Are you sure you want to build a new app? (Y/n)'
      r = $stdin.getch

      if r[/y|\r/i] then
        IO.popen(command).each_line {|x| print "", x}
      else
        puts 'Abort'
      end
    end
    @h
  end

  def save()
    File.write "#{@app}.cfg", @config
  end

  private

  def parse(patterns, s=nil)

    if s.nil? then

      # is there a directory called site1?

      dir = 'site1'

      while File.exists? dir do
        i = dir.slice!(/\d+$/).to_i; dir += (i+=1).to_s 
      end


      s =<<EOF
#
#   railsbuilder configuration file
#
app: #{dir}

# resources: posts
EOF
    end
    @config = s
    a = LineParser.new(patterns).parse s
    a.group_by(&:first)
  end

end

=begin

# basic example

rb = RailsBuilder.new
r = rb.build
rb.save

=end
