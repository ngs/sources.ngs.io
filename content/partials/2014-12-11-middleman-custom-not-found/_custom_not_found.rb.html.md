require 'middleman-core'
class CustomNotFound < ::Middleman::Extension
  option :error_page, 'error.html', 'Path for error page. `error.html` by default.'
  def initialize(app, options_hash={}, &block)
    super
    error_page = options.error_page
    app.before do
      path = ::Middleman::Util.normalize_path req.path
      path = 'index.html' if path.empty?
      sitemap.ensure_resource_list_updated!
      unless sitemap.find_resource_by_destination_path path
        paths = sitemap.instance_variable_get :@_lookup_by_destination_path
        paths[path] = paths[error_page]
      end
      true
    end
  end
end
::Middleman::Extensions.register(:custom_not_found, CustomNotFound)
