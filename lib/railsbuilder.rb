#!/usr/bin/env ruby

# file: railsbuilder.rb

require 'fileutils'
require 'io/console'
require 'lineparser'


class RailsBuilder
  
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
          [:resource_cv, /(\w+)(?:\s+[av]{1,2})?/, :resource_cv_av],
      [:all, /^\s*#/, :comment]
    ]

    parse(patterns, buffer)
  end

  def build()

    doc = self.to_doc.root

    @app = app = doc.element('app/@app')
    return unless app

    app_path = doc.element('app_path/@app_path')

    Dir.chdir app_path if app_path

    unless File.exists? app then

      command = 'rails new ' + app
      puts ":: preparing to execute shell command: `#{command}`"
      puts 'Are you sure you want to build a new app? (Y/n)'

      shell command
    end

    Dir.chdir app

    # select the :resource records
    root = doc.element('root/@root')

    routes = File.join('config','routes.rb')

    if root then

      # check if the config/routes.rb file needs updated

      buffer = File.read routes

      regex = /  #( root 'welcome#index')/

      if buffer[regex] or not buffer[/root '#{root}'/] then      
        puts ':: updating ' + routes
        File.write routes, buffer.sub(regex, ' \1')\
                        .sub(/'[^']+'/,"'" + root + "'")
      end
    end

    resources = doc.element('resources/@resources')    

    if resources then

      buffer = File.read routes

      if not buffer[/\n\s*resources :#{resources}/] then

        puts ':: updating ' + routes
        File.write routes, buffer.sub(/\n  resources :\w+/,'')\
          .sub(/ #   resources :products/) \
            {|x| x + "\n  resources :#{resources}"}
      end
    end

    doc.xpath('resource').each do |node|

      resource = node.attributes[:resource]

      puts 'resource : ' + resource.inspect
      next unless resource

      controller = resource + '_controller.rb'
      controller_file = File.join('app','controllers', controller)

      node.each do |child|

        case child.name.to_sym

          when :model

            # does the controller exitst?

            unless File.exists? controller_file then

              command = "rails g controller %s" % resource
              puts ":: preparing to execute shell command: `#{command}`"
              puts 'Are you sure you want to generate a controller? (Y/n)'

              shell command            
            end

          when :resource_cv

            # fetch the action name
            action = child.element 'resource_cv_av/@captures0'

            if action then

              page = action + '.html.erb'
              view_file = File.join('app','views', resource, page)
          
              #   if the controller exists don't try to generate the view,
              # instead add the entry to the controller file and
              # create the view file


              if File.exists? controller_file then

                buffer = File.read controller_file

                regex = /class \w+Controller < ApplicationController/
                buffer.sub!(regex) {|x|  x + "\n\n  def new\n  end\n" }
                File.write controller_file, buffer
                puts ':: updated ' + controller
      
                File.write view_file, ''
                puts ':: created ' + page

              else

                unless File.exists? view_file then

                  command = "rails generate controller %s %s" % [resource, action]
                  puts ":: preparing to execute shell command: `#{command}`"
                  puts 'Are you sure you want to generate a controller action? (Y/n)'

                  shell command
                end
              end
            end

        end # /case when
      end # / child iterator
    end

  end

  def save()
    File.write "#{@app}.cfg", @config
  end

  def to_doc()
    Rexle.new(@lp.to_xml)
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
    @lp = LineParser.new(patterns)
    @lp.parse s

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