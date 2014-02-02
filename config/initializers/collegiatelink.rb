ENV['CL_APIKEY']      ||= 'your api key'
ENV['CL_IP']          ||= 'your ip' # or nil
ENV['CL_PRIVATEKEY']  ||= 'your private key'
ENV['CL_SOCKS']       ||= 'your socks proxy'
ENV['CL_SOCKS_PORT']  ||= 'your socks proxy port'
COLLEGIATELINK = CollegiateLink::Client.new(apikey: ENV['CL_APIKEY'],
                                            ip: ENV['CL_IP'],
                                            privatekey: ENV['CL_PRIVATEKEY'])
COLLEGIATELINK.use_socks_proxy(ENV['CL_SOCKS'], ENV['CL_SOCKS_PORT'])

USG_MEMBERS = COLLEGIATELINK.roster(14280)
USG_VP_FINANCE = USG_MEMBERS.detect do |p|
  p.current? && p.positionName == 'Vice-President of Finance'
end
USG_TREASURERS = USG_MEMBERS.select do |p|
  p.current? && p.positionName == 'Treasurer'
end
