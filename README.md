# Building a new Rails app with the railsbuilder gem

    require 'railsbuilder'

    rb = RailsBuilder.new
    rb.build 
    rb.save

The above code will create a new Rails app called *site1* and then it will save file *site1.cfg* containing the following:

<pre>
#
#   RailsBuilder configuration file
#
app: site1

# resources: posts
</pre>

# Creating a basic app with Railsbuilder

In this guide we will create a blog. Create the config file for the blog as show below:
<pre>
#
#  railsbuilder configuration file
#

app: blog
</pre>

Then run *railsbuilder* e.g.

    require 'railsbuilder'

    rb = RailsBuilder.new '~/rails/blog.cfg'
    rb.build

It will ask you if want to create a new app, press enter or type *y*.

Type `rails server` and observe the web page displayed at http://localhost:3000.


## Creating the controller

Add a controller entry called 'welcome' with a method called 'index' to the config file as show below:

<pre>
#
#  railsbuilder configuration file
#

app: blog

welcome
  controller + views
    index
</pre>

The run *railsbuilder* again, it should ask you if you want to generate a new controller. Press *y* or press *enter*.

Edit the file `app/views/welcome/index.html.erb` and replace the *H1* tag contents with "*Hello, Rails*". Then delete the paragraph block below it.

## Setting the application home page
Add a root entry called 'welcome#index' to the config file as shown below:

<pre>
#
#  railsbuilder configuration file
#

app: blog
root: welcome#index

welcome
  controller + views
    index
</pre>

Save the file and then run railsbuilder again. Observe it displayed the message **:: updating config/routes.rb**.

Observe localhost:3000 now displays the content from welcome/index.

Note: This gem is currently under development.

## Resources

* [jrobertson/railsbuilder](https://github.com/jrobertson/railsbuilder)

rails railsbuilder config gem builder
