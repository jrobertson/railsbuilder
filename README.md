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

Note: This gem is currently under development.

## Resources

* [jrobertson/railsbuilder](https://github.com/jrobertson/railsbuilder)

rails railsbuilder config gem builder
