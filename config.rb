###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :life do
page "/elena.html", :layout => false
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# activate :livereload

# Methods defined in the helpers block are available in templates

require 'active_support/core_ext'

helpers do
  def tag_url tag
    link_to tag, "/blog/categories/#{tag}"
  end

  def site_url(protocol = 'http')
    if development?
      "#{protocol}://localhost:4567"
    else
      "#{protocol}://evtuhovich.ru"
    end
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :haml, :ugly => true

Time.zone = "Moscow"

activate :blog do |blog|
  blog.name = "life"
  blog.prefix = "life"
  blog.permalink = ":year/:month/:day/:title/index.html"
  blog.taglink = "categories/:tag/index.html"
  blog.layout = 'layouts/life-post'
  blog.summary_separator = /(<!-- more -->)/
  blog.summary_length = nil
  # blog.year_link = ":year.html"
  # blog.month_link = ":year/:month.html"
  # blog.day_link = ":year/:month/:day.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "life/tag.html"
#  blog.calendar_template = "blog/calendar.html"

  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "/life/page/:num"
  # blog.publish_future_dated = true
  # blog.custom_collections = {
  #   categories: {
  #     link: '/categories/{categories}/',
  #     template: '/category.html'
  #   }
  # }
end

activate :blog do |blog|
  blog.name = "blog"
  blog.prefix = "blog"
  blog.sources = '{year}/{year}-{month}-{day}-{title}.html'
  blog.permalink = ":year/:month/:day/:title/index.html"
  # blog.sources = ":year-:month-:day-:title.html"
  blog.taglink = "categories/:tag/index.html"
  blog.layout = 'layouts/blog-post'
  blog.summary_separator = /(<!-- more -->)/
  blog.summary_length = nil
  # blog.year_link = ":year.html"
  # blog.month_link = ":year/:month.html"
  # blog.day_link = ":year/:month/:day.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "blog/tag.html"
#  blog.calendar_template = "blog/calendar.html"

  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "/blog/page/:num"
  # blog.publish_future_dated = true
  # blog.custom_collections = {
  #   categories: {
  #     link: '/categories/{categories}/',
  #     template: '/category.html'
  #   }
  # }
end

activate :syntax

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true
# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

activate :s3_sync do |s3_sync|
  s3_sync.bucket                     = 'evtuhovich.ru'
  s3_sync.region                     = 'eu-west-1'
  s3_sync.delete                     = false # We delete stray files by default.
end
