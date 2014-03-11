#!/usr/bin/env ruby

# file: railsbuilder.rb

require 'fileutils'
require 'io/console'
require 'lineparser'


class RailsBuilder
  
  attr_reader :to_h

  def initialize(filepath=nil)

    buffer = File.read File.expand_path(filepath) if filepath

    patterns = [
      [:root, 'app_path: :app_path', :app_path],
      [:root, 'app: :app', :app],
      [:root, 'root: :root', :root],
      [:root, 'resources: :resources', :resources],
      [:root, ':resource', :resource],
        [:resource, 'model', :model],
          [:model, ':class_name', :model_class],
        [:resource, /controller \+ views/, :resource_cv],
          [:resource_cv, /(\w+)\s+[av]{1,2}/, :resource_cv_av],
      [:all, /^\s*#/, :comment]
    ]

    @to_h = @h = parse(patterns, buffer)
  end

  def build()

    @app = @h[:app][0][1][':app']
    app_path = @h[:app][0][1][':app_path']
    Dir.chdir app_path if app_path

    unless File.exists? @app then

      command = 'rails new ' + @app
      puts ":: preparing to execute shell command: `#{command}`"
      puts 'Are you sure you want to build a new app? (Y/n)'

      shell command
    end

    Dir.chdir @app

    # select the :resource records
    root = @h[:root][0][1][":root"]

    if root then

      # check if the config/routes.rb file needs updated
      routes = File.join('config','routes.rb')
      buffer = File.read routes

      regex = /  #( root 'welcome#index')/

      if buffer[regex] or not buffer[/root #{root}/] then      
        puts ':: updating ' + routes
        File.write routes, buffer.sub(regex, ' \1')\
                        .sub(/'[^']+'/,"'" + root + "'")
      end
    end

    @h[:resource].each do |raw_resource|

      resource_child = raw_resource[3][0]
      resource = raw_resource[1][":resource"]

      case resource_child[0]

        when :model_class
          puts "it's a model"
        when :resource_cv

          # fetch the action name
          action = resource_child[3][0][1][:captures][0]
          page = action + '.html.erb'
      
          unless File.exists? File.join('app','views', resource, page) then

            command = "rails generate controller %s %s" % [resource, action]
            puts ":: preparing to execute shell command: `#{command}`"
            puts 'Are you sure you want to generate a controller action? (Y/n)'

            shell command
          end

      end
    end

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