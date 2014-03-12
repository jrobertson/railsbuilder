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

# Adding CRUD to the app

Following on from creating the basic app with a welcome page we are now ready to continue.

## Defining resources

Within the config file add the *resources* statement as show below:

<pre>
#
#  railsbuilder configuration file
#

app: blog
root: welcome#index
resources: posts

welcome
  controller + views
    index
</pre>

## Creating a Posts controller

Add the *posts* statement to the config file before the welcome line. Then after *posts* on the next line, indent by 2 spaces and add the *model* statement. Then on the next line indented by 2 spaces add the *controller + views* statement.

## Adding an action to the controller

Looking at the config file, within the context of *controllers + views* on the next line, indented by 4 spaces add the *new* statement. This instructs *railsbuilder* to create a method called *new* in the `posts_controller.rb` file.

The config file should now look similar to the following:

<pre>
#
#  railsbuilder configuration file
#

app: blog
root: welcome#index
resources: posts

posts
  model
  controller + views
    new
welcome
  controller + views
    index
</pre>

Run *railsbuilder* again, this time try defining an alias command and running it from the command line e.g.

`alias build="ruby -r railsbuilder -e \"RailsBuilder.new('~/rails/blog.cfg').build\""`

type: `build`

Note: It would be convenient to store this alias in your bash aliases file.

Now that the *new* view has been created we could add a form with a submit button, however leave that until later. 

## Adding an action for submitting a post

When the submit button is pressed its request should be processed by the *create* method.

Looking at the config file, within the *controllers + views* section, after *new*, add a new line, indented by 4 spaces, add the statement *create*.

Here's how your config file should look:

<pre>
#
#  railsbuilder configuration file
#

app: blog
root: welcome#index
resources: posts

posts
  model
  controller + views
    new
    create
welcome
  controller + views
    index
</pre>

If you run *railsbuilder* now, it will create the *create* method within posts_controller.rb file.

## Creating the model

To declare the record fields we will need, add a new line indented by 4 spaces after the *model* statement, and add the statement *Post*. Then on a new line indented by 6 spaces add the couple of field definitions as show below:

<pre>
#
#  railsbuilder configuration file
#

app: blog
root: welcome#index
resources: posts

posts
  model
    Post
      title: string
      text:  text
  controller + views
    new
    create
welcome
  controller + views
    index
</pre>

Run *railsbuilder* and accept the confirmation to generate the model, and migrate the database.


Note: This gem is currently under development.

## Resources

* [jrobertson/railsbuilder](https://github.com/jrobertson/railsbuilder)

rails railsbuilder config gem builder
