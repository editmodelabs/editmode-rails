# EditMode for Rails

The Editmode gem allows you to interact with and display content from the Editmode platform.

## Installation

#### 1. Add the gem to your Gemfile:
```ruby
gem 'editmode'
```
And run `bundle install`.

#### 2. Create an initializer with your project_id

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

## Table of Contents
- [Accessing chunk content in your application](#accessing-chunk-content-in-your-application)
- [Caching](#caching)
- [Disabling editmode.js auto-include](#disabling-editmodejs-auto-include)

## Displaying chunks in your rails views
Editmode provides helper methods for use within Rails layouts and views.

##### Embedding a Collection

```erb
<% c('COLLECTION_ID', :limit => 10, :tags => ['Tag A', 'Tag B']) do |parent_object| %>
  <div class="user-profile">
    <h3 class="user-name">
      <%= chunk_field_value(parent_object, field_id) %>
    </h3>
    <p class="description">
      <%= chunk_field_value(parent_object, field_id) %>
    </p>
  </div>
<% end %>
```

|Parameter|Type|Description|
|---|---|---|
| identifier | string | The first argument of `chunk_collection` takes the id of the collection you want to loop through |
| limit | int |`optional` The number of collection item you want to display  |
| tags | array |`optional` Filter collection items based on tags listed in this parameter  |
| parent_object | object | The first argument of `chunk_field_value` takes the chunk object passed in from the `chunk_collection` loop |
| field_id | string | The second argument of `chunk_field_value` takes the id of the collection field you want to reference |

## Accessing chunk content in your application
Often you will want to use the raw content of a chunk inside a controller or somewhere else in your application. You can use `Editmode.chunk_value` for this.

##### You can also use variables in returned chunk_values
```ruby
variable_values = { first_name: "Dexter", last_name: "Morgan"}

# Assume chunk content is "Hi {{first_name}} {{last_name}}"

# Single Chunk with Variables
e("cnk_d36415052285997e079b", values: variable_values)

# Collection Field with Variables
e("cnk_16e04a02d577afb610ce", "Email Content", values: variable_values)

# Response: "Hi Dexter Morgan"
```
[Read more about variables](core_concepts?id=variables)


## Caching

In order to keep your application speedy, Editmode minimizes the amount of network calls it makes by caching content where it can. 

#### What's cached

- Any embedded content returned by the `e`, `E`, `f`, or `F` view helpers.

#### What's not cached
- Content returned by `<chunk_collection>`. Editmode will make one network call for every `<chunk_collection>` on any given page. (But not for the embedded `<chunk_field_value>` method)

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

