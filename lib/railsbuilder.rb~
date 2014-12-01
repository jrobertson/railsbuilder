#!/usr/bin/env ruby

# file: railsbuilder.rb

require 'fileutils'
require 'io/console'
require 'lineparser'
require 'rdiscount'
require 'yaml'
require 'rxfhelper'
require 'tmpdir'
require 'activity-logger'


class RailsBuilder
  

  def initialize(s=nil, journal: false)

    @config = RXFHelper.read(s)[0].gsub(/^(\s{,5})#/,'\1;') if s
    @tmp_path = @journal = journal == true ? Dir.tmpdir : journal  if journal

    patterns = [
      [:root, 'app_path: :app_path', :app_path],
      [:root, 'app: :app', :app],
      [:root, 'root: :root', :root],
      [:root, 'resources: :resources', :resources],
      [:root, ':resource', :resource],
        [:resource, 'model', :model],
          [:model, ':class_name', :model_class],
            [:model_class, /(\w+):\s*(string|text)/, :class_attribute],
        [:resource, /(?:controller \+ views|actionpack:)/, :resource_cv],
          [:resource_cv, /(\w+)(?:\s+([av]{1,2}))?/, :resource_cv_av],
            [:resource_cv_av, /(markdown):\s*(.*)/, :renderer],
              [:renderer, /.*/, :render_block],
      [:all, /^\s*;/, :comment]
    ]

    xml = parse(patterns, @config)
    @doc = Rexle.new xml

    @parent_path = Dir.pwd
    @notifications = []
  
  end

  def build(auto: false, desc: nil)

    doc = @doc.root
    @auto_override = auto
  
    @app = app = doc.element('app/@app')
    return unless app
    
    unless File.exists? app then

      command = 'rails new ' + app
      puts ":: preparing to execute shell command: `#{command}`"
      puts 'Are you sure you want to build a new app? (Y/n)'

      shell command

      trigger = "config: new app entry found which doesn't yet " \
                                            + "exist as a file directory"
      activity = "new Rails app created"
      @notifications << [trigger,activity]

    else

    end

    @app_path = app_path = doc.element('app_path/@app_path') || 
                                           File.join(@parent_path, app)

    Dir.chdir app_path

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

        trigger = "config: new root added or changed"
        activity = "file: config/routes.rb modified"
        data = /^\s*root\s+'#{root}'/
        @notifications << [trigger, activity, data]
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

        trigger = "config: resources entry has been changed"
        activity = "file: config/routes.rb modified"
        data = /resources\s+:#{resources}/
        @notifications << [trigger, activity, data]
      end
    end

    doc.xpath('resource').each do |node|
      
      resource = node.attributes[:resource]

      next unless resource

      controller = resource + '_controller.rb'
      controller_file = File.join('app','controllers', controller)

      node.elements.each do |child|

        case child.name.to_sym

          when :model

            # does the controller exitst?

            unless File.exists? controller_file then

              command = "rails g controller %s" % resource
              puts ":: preparing to execute shell command: `#{command}`"
              puts 'Are you sure you want to generate a controller? (Y/n)'

              shell command            

              trigger = "config: model found for a controller which " + "doesn't yet exist"
              activity = "file: created app/controllers/posts_controller.rb"
              @notifications << [trigger, activity]
            end

            # if the model fields are defined let's generate the model
            model = child.element('model_class')
            next unless model

            class_name = model.attributes[:class_name]
            next unless class_name

            attributes = model.xpath('.').map {|x| x.attributes.values}

            next if attributes.empty?

            s = class_name + ' ' + attributes.map{|x| x.join ':'}.join(' ')

            command = "rails generate model %s" % s
            puts ":: preparing to execute shell command: `#{command}`"
            puts 'Are you sure you want to generate a model? (Y/n)'

            r = shell command
            next if r == :abort

            trigger = "config: a new model with associated entries has "\
                                                              + "been found"
            activity = "file: created app/models/#{class_name.downcase}.rb"
            @notifications << [trigger, activity]

            # -- next command ---------------------

            command = "rake db:migrate"     

            puts ":: preparing to execute shell command: `#{command}`"
            puts 'Are you sure you want to commit this '\
                                              + 'database operation? (Y/n)'
            shell command

            trigger = "... continuation from previous trigger"
            activity = "database: created"
            @notifications << [trigger, activity]

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

                unless File.exists? view_file then

                  File.write view_file, ''
                  puts ':: created ' + page

                  trigger = "config: the 1st action has been "\
                                              + "created in the controller"
                  activity = "file: created " + view_file
                  @notifications << [trigger, activity]

                end

                child.elements.each do |av|

                  action = av.attributes[:captures0]
                  next unless action
                  page = action + '.html.erb'

                  unless buffer[/\bdef #{action}/] then

                    buffer.sub!(regex) {|x|  x + "\n  def #{action}\n  end\n" }
                    File.write controller_file, buffer
                    puts ':: updated ' + controller

                    trigger = "config: an action has been "\
                                + "created in the controller + views section"
                    activity = "file: updated " + controller_file
                    data = /def #{action}/
                    @notifications << [trigger, activity, data]
                  end

                  av_type = av.attributes[:captures1]
                  next unless av_type

                  if av_type[/v/] then

                    page = action + '.html.erb'
                    view_file = File.join('app','views', resource, page)

                    unless File.exists? view_file then
                      File.write view_file, ''
                      puts ':: created ' + page

                      trigger = "config: an action has been "\
                                 + "created in the controller + views section"
                      activity = "file: updated " + controller_file
                      data = /def #{action}/
                      @notifications << [trigger, activity, data]
                    end                   

                    # does it contain a renderer? e.g. markdown
                    renderer = av.element 'renderer'
                    next unless renderer

                    type, text = renderer.attributes.values
                    #   open the related page and add the content if it
                    # doesn't already exist

                    render_block = renderer.text('render_block')

                    raw_text = if text and render_block then
                      text + "\n" + render_block
                    elsif text then text
                    elsif render_block then render_block
                    end
                      
                    if type == 'markdown' and raw_text then

                      html = RDiscount.new(raw_text).to_html
                      buffer = File.read view_file

                      unless buffer[/#{html}/] then
                        File.write view_file, html + "\n" + buffer
                        puts ':: updated ' + view_file

                        trigger = "config: a rendering block has been "\
                                      + "created or modified for an action"
                        activity = "file: updated " + view_file
                        data = /#{html}/
                        @notifications << [trigger, activity, data]
                      end
                    end

                  end
                end      

              else

                unless File.exists? view_file then
                  
                  actions = child.xpath('resource_cv_av') do |x| 
                    x.attributes[:captures0]
                  end.join(' ')

                  command = "rails generate controller %s %s" % 
                                                          [resource, actions]
                  puts ":: preparing to execute shell command: `#{command}`"
                  puts 'Are you sure you want to generate a ' \
                                                + 'controller action? (Y/n)'
                  shell command

                  trigger = "config: a new action has been "\
                         + "created in the controller + views section for a "\
                         + "resource which doesn't have a model and the "\
                         + "controller file doesn't yet exist."
                  activity = "file: created " + controller_file
                  @notifications << [trigger, activity]

                end
              end
            end

        end # /case when
      end # / child iterator
    end

    snapshot(desc) if @journal and @notifications.any?
    Dir.chdir @parent_path
    @notifications.to_yaml
  end

  def notifications
    @notifications.to_yaml
  end

  def restore(level=-2)
    
    base = File.join(@tmp_path, 'railsbuilder', @app)
    dx = Dynarex.new File.join(base, 'dynarexdaily.xml')
    a = dx.all
    return 'no restore points available' if a.length < 1

    level = 0 if a.length < 2
    record = a[level]
    path = a[level].desc[/^[^;]+/]

    FileUtils.rm_rf @app_path
    FileUtils.copy_entry File.join(base, path), @app_path, preserve=true
    a.last.delete
    dx.save

    path + ' app restored'
  end

  def save(filepath=@parent_path)
    File.write File.join(filepath, "#{@app}.cfg"), @config
  end

  def to_doc()
    @doc
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
    LineParser.new(patterns, s).to_xml

  end

  def shell(command)

    return system command if @auto_override

    if $stdin.getch[/y|\r/i]then
      IO.popen(command).each_line {|x| print "", x}
    else
      puts 'Abort'
      :abort
    end
  end

  def snapshot(desc=nil)    

    d = Time.now.strftime("%d-%b").downcase
    t = Time.now.strftime("%H%M_%S.%2N")
    snapshot_path = File.join(@tmp_path, 'railsbuilder', @app, d,t)
    FileUtils.mkdir_p snapshot_path

    FileUtils.copy_entry @app_path, snapshot_path, preserve=true
    al = ActivityLogger.new File.join(@tmp_path, 'railsbuilder', @app)
    s = File.join(d,t)
    s << '; ' + desc if desc
    al.create s

    self.save snapshot_path
  end

end

=begin

# basic example

rb = RailsBuilder.new
r = rb.build
rb.save

=end
