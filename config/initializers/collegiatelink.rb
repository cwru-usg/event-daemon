ENV['CL_APIKEY']     ||= 'your api key'
ENV['CL_IP']         ||= 'your ip'
ENV['CL_SHAREDKEY']  ||= 'your shared key'
ENV['CL_SOCKS']      ||= 'your socks proxy'
ENV['CL_SOCKS_PORT'] ||= 'your socks proxy port'
COLLEGIATELINK = CollegiateLink::Client.new(ENV['CL_APIKEY'], ENV['CL_IP'], ENV['CL_SHAREDKEY'])
COLLEGIATELINK.use_socks_proxy(ENV['CL_SOCKS'], ENV['CL_SOCKS_PORT'])

USG_MEMBERS = COLLEGIATELINK.roster(14280)
USG_VP_FINANCE = USG_MEMBERS.detect do |p|
  p.current? && p.positionName == 'Vice-President of Finance'
end
USG_TREASURERS = USG_MEMBERS.select do |p|
  p.current? && p.positionName == 'Treasurer'
end
