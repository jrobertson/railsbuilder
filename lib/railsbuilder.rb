#!/usr/bin/env ruby

# file: railsbuilder.rb

require 'fileutils'
require 'io/console'
require 'lineparser'


class RailsBuilder
  
  attr_reader :to_a

  def initialize(filepath=nil)

    buffer = File.read filepath if filepath

    patterns = [
      [:root, 'app_path: :app_path', :app_path],
      [:root, 'app: :app', :app],
      [:root, 'resources: :resources', :resources],
      [:root, ':resource', :resource],
        [:resource, 'model', :model],
          [:model, ':class_name', :model_class],
        [:resource, 'controller + views', :resource_cv],
          [:resource_cv, /(\w+)\s+[av]{1,2}/, :resource_cv_av],
      [:all, /#/]
    ]

    @to_a = @a = parse(patterns, buffer)
  end

  def build()

    cols = @a[:root].select {|x| x[1].has_key? ':app' }
    @app = cols[0][1][':app']

    unless File.exists? @app then
      command = 'rails new ' + @app
      puts ":: preparing to execute shell command: `#{command}`"
      puts 'Are you sure you want to build a new app? (Y/n)'

      shell command
    else
      Dir.chdir @app
    end

    # select the :resource records

    @a[:root].select{|x| x[1][":resource"]}.each do |raw_resource|

      resource_child = raw_resource[3][0][3]
      resource = raw_resource[1][":resource"]

      case resource_child[0][0]

        when :model
          puts "it's a model"
        when :resource_cv

          # fetch the action name
          action = resource_child[0][1][:captures][0]
          page = action + '.html.erb'
      
          unless File.exists? File.join('app','views', resource, page) then

            command = "rails generate controller %s %s" % [resource, action]
            puts ":: preparing to execute shell command: `#{command}`"
            puts 'Are you sure you want to generate a controller action? (Y/n)'

            shell command
          end

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

  def shell(command)

    if $stdin.getch[/y|\r/i] then
      IO.popen(command).each_line {|x| print "", x}
    else
      puts 'Abort'
    end
  end
end

=begin

# basic example

rb = RailsBuilder.new
r = rb.build
rb.save

=end