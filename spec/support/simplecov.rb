# Run Coverage report
require 'simplecov'

SimpleCov.start do
  add_filter 'spec/dummy'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Models', 'app/models'
  add_group 'Views', 'app/views'
  add_group 'Delegators', 'app/delegators'
  add_group 'Policies', 'app/policies'
  add_group 'Renderers', 'app/renderers'
  add_group 'Converters', 'app/converters'
  add_group 'Exporters', 'app/exporters'
  add_group 'Jobs', 'app/jobs'
  add_group 'Permuters', 'app/permuters'
  add_group 'Presenters', 'app/presenters'
  add_group 'Services', 'app/services'
  add_group 'Libraries', 'lib'
end
