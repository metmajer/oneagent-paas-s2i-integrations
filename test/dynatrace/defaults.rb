module Dynatrace
  class Defaults
    DT_TENANT = ''
    DT_TENANTTOKEN = ''
    DT_API_TOKEN = ''
    DT_CLUSTER_HOST = "#{Dynatrace::Defaults::DT_TENANT}.dev.dynatracelabs.com"
  end
end
