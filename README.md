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

#### 3. (Rails 6) Ensuring the Magic Editor works with Content Security Policy

- Add "https://static.editmode.com" to `style_src` and `script_src` in your content security policy.
- Add "https://api.editmode.com" to `connect_src` in your content security policy.

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
<%= E('cnk_x4ts...', class: "a-css-class") %> # Render a chunk with inline css class 
```

### Working with multiple projects in the same codebase
If you want to include content from a different project to the one you've specified in the initializer, you can pass the project id in to the view helper.
```erb
<%= E("cnk_16e04a02d577afb610ce", project_id: "prj_02d577afb617hdb") %>
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
<%= c('col_j8fbs...', class: "profiles-container", item_class: "profile-item") do %>
  <h3 class="name">
    <%= F("Name", class: "profile-name") %>
  </h3>
  <p class="description">
    <%= f("Description"), class: "profile-description" %>
  </p>
<% end %>
```

|Parameter|Type|Description|
|---|---|---|
| identifier | string | The first argument of `c` takes the id of the collection you want to loop through |
| limit | int/string |`optional` The number of collection items you want to display  |
| tags | array |`optional` Filter collection items based on tags listed in this parameter  |
| class | string | `optional` Class name(s) that will be added along with "chunks-collection-wrapper" to the main collection `<div>` element |
| item_class | string | `optional` Class name(s) that will be added along with "chunks-collection-item--wrapper" to all collection items |


### Working with Image Transformation
Use `transformation` attribute to perform real-time image transformations to deliver perfect images to the end-users.

```ruby
# This chunk should render an image with 200 x 200 dimension
= E('id-of-some-image', transformation: "w-200 h-200")

# For image inside a collection
= c('some-collection-id') do
  = F('Avatar', transformation: "w-200 h-200")
```

Please see the complete list of [transformation parameters](https://editmode.com/docs#/imagekit_properties).

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

?> We are using a method called `delete_matched` to purge your caches when a content gets updated, and this method isn't supported in `memcached`. We highly recommend using `redis_store` or `file_store`.

## Disabling editmode.js auto-include

To disable automatic insertion for a particular controller or action you can:
```ruby
 skip_after_action :editmode_auto_include
```

