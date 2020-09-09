<p align="center">
  <img src="https://editmode.s3-eu-west-1.amazonaws.com/static/editmode-full-navy-bg-transparent.png" width="260" />
</p>
<br />

# EditMode for Rails

Editmode is a smarter way to manage copy and other content in your rails app. It's syntax is similar to i18n, but it's built for copy updates, not internationalization (yet). It's built around the idea of moving your content out of your codebase.

## Installation

#### 1. Add the gem to your Gemfile:
```ruby
gem 'editmode'
```
And run `bundle install`.

#### 2. Create an initializer with your project_id

<small>Don't have a project id? Sign up for one [here](https://editmode.com/rails?s=ghreadme)</small>

```sh
  rails generate editmode:config YOUR-PROJECT-ID
```
This command produces an initializer file 
```ruby
# config/initializers/editmode.rb
Editmode.setup do |config|
  config.project_id={project_id}
end
```

That's it, you're all set up. By default Editmode will now include editmode.js in every page of your rails application, unless you disable auto-include.
<hr/>

## Rendering Content

Editmode provides helper methods for use in your rails views and controllers.

### Render the content of a chunk
```erb
<%= e('cnk_x4ts............') %> # Using a chunk identifier
<%= e('marketing_page_headline') %> # Using a content key 
```

### Render an *Editable* chunk. Wait, [what?](https://editmode.com/rails) 
```erb
<%= E('cnk_x4ts............') %> # Using a chunk identifier
<%= E('marketing_page_headline') %> # Using a content key
```

### Content can also be accessed in Controllers
```ruby
@page_title = e("cnk_x4ts............")  # Using a chunk identifier
@page_title = e("marketing_page_seo_title") # Using a content key
```

### Directly get the value of a custom field
This works when a chunk is part of a collection.
```ruby
@email_subject = e("welcome_email","Subject")
@email_content = e("welcome_email","Content")
```

### Working with variables
```ruby
variable_values = { first_name: "Dexter", last_name: "Morgan"}

# Assume chunk content is "Hi {{first_name}} {{last_name}}"

# Single Chunk with Variables
e("cnk_d36415052285997e079b", variables: variable_values)

# Collection Field with Variables
e("cnk_16e04a02d577afb610ce", "Email Content", variables: variable_values)

# Response: "Hi Dexter Morgan"
```

### Use collections for repeatable content
```erb
<% c('col_j8fbs...', :limit => 10, :tags => ['US']) do |chunk| %>
  <div class="user-profile">
    <h3 class="name">
      <%= F("Name") %>
    </h3>
    <p class="description">
      <%= f("Description") %>
    </p>
  </div>
<% end %>
```

|Parameter|Type|Description|
|---|---|---|
| identifier | string | The first argument of `c` takes the id of the collection you want to loop through |
| limit | int |`optional` The number of collection items you want to display  |
| tags | array |`optional` Filter collection items based on tags listed in this parameter  |


## Caching
In order to keep your application speedy, Editmode minimizes the amount of network calls it makes by caching content where it can. 

#### What's cached
- Any embedded content returned by the `e`, `E`, `f`, or `F` view helpers.

#### Expiring the cache

The editmode gem exposes a cache expiration endpoint in your application at `/editmode/clear_cache`.

1. GET `/editmode/clear_cache?identifier={chunk_id}` clears the cache for a specific chunk.
2. GET `/editmode/clear_cache?full=1` clears the full Editmode cache.

- Editmode.js will automatically hit this endpoint when you update a chunk through your frontend.
- You can configure cache expiration webhooks in Editmode.com to ensure your application is notified when content changes happen on Editmode.com

The cache expiration endpoint is currently **not** authenticated.

## Disabling editmode.js auto-include

To disable automatic insertion for a particular controller or action you can:
```ruby
 skip_after_action :editmode_auto_include
```

