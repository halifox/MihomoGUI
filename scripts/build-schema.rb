require 'yaml'
require 'json'
root = ARGV[0] || '/Users/user/IdeaProjects/Meta-Docs-main/docs/config'
def samples(text)
  text.scan(/```(?:\{\.yaml[^\n]*\}|yaml)[^\n]*\n(.*?)```/m).map do |match|
    raw = match[0].lines.map do |line|
      line = line.gsub('：', ':')
      line = line.gsub(/\[([^\]\n]*)\]/) do
        '[' + $1.split(',').map { |item| v=item.strip; v.include?(':') && v !~ /^["']/ ? "'#{v}'" : v }.join(', ') + ']'
      end
      if line =~ /^(\s*)# ?(\s*(?:[\w.-]+:|-(?:\s|$)).*)$/
        $1 + $2 + "\n"
      else
        line
      end
    end.join
    raw = raw.gsub(/^(\s*-\s*)(::[^\s#]+)/) { "#{$1}'#{$2}'" }
    begin
      value = YAML.safe_load(raw, [Symbol], [], true)
      value.is_a?(Hash) ? value : nil
    rescue Psych::Exception => e
      warn "#{$doc_label}: #{e.message.lines.first}"
      nil
    end
  end.compact
end
def merge(a,b)
  b.each do |k,v|
  next if a[k].is_a?(Hash) && (v.nil? || v=='...')
  a[k] = a[k].is_a?(Hash) && v.is_a?(Hash) ? merge(a[k],v) : v
 end
  a
end
def descriptions(text)
  result={}
  text.scan(/^\#{2,5}\s+([^\n]+)\n(.*?)(?=^\#{1,5}\s|\z)/m).each do |key,body|
    clean=body.gsub(/```.*?```/m,'').gsub(/!\!\!.*\n/,'').gsub(/\[([^\]]+)\]\([^)]*\)/,'\1').gsub(/[*`]/,'').gsub(/\s+/,' ').strip
    result[key.downcase]=clean[0,260]
  end
  result
end
CHOICES={
 'mode'=>%w[rule global direct], 'log-level'=>%w[silent error warning info debug],
 'find-process-mode'=>%w[always strict off], 'geodata-loader'=>%w[memconservative standard],
 'dns.cache-algorithm'=>%w[lru arc], 'dns.enhanced-mode'=>%w[fake-ip redir-host],
 'dns.fake-ip-filter-mode'=>%w[blacklist whitelist rule], 'tun.stack'=>%w[system gvisor mixed mips],
 'tun.congestion-controller'=>%w[cubic reno bbr bbr3],
 'ip-version'=>%w[dual ipv4 ipv6 ipv4-prefer ipv6-prefer], 'smux.protocol'=>%w[h2mux smux yamux],
 'client-fingerprint'=>%w[chrome firefox safari ios android edge 360 qq random],
 'bbr-profile'=>%w[standard conservative aggressive], 'udp-relay-mode'=>%w[native quic],
 'congestion-controller'=>%w[cubic reno bbr bbr3], 'packet-encoding'=>%w[xudp packetaddr],
 'network'=>%w[tcp ws grpc h2 http], 'restls-opts.version-hint'=>%w[tls12 tls13], 'obfs-opts.mode'=>%w[http tls shadow-tls restls jls]
}
MAP_KEYS=%w[hosts nameserver-policy proxy-server-nameserver-policy headers ws-opts.headers http-opts.headers h2-opts.headers]
def fields(hash,prefix='',desc={})
 hash.flat_map do |key,value|
  path=prefix.empty? ? key.to_s : "#{prefix}.#{key}"
  if value.is_a?(Hash) && !MAP_KEYS.include?(key.to_s) && !MAP_KEYS.include?(path)
   fields(value,path,desc)
  else
   kind = case value
    when TrueClass,FalseClass then 'boolean'
    when Integer then 'integer'
    when Numeric then 'number'
    when Array then 'list'
    when Hash then 'map'
    else 'string'
   end
   kind='secret' if key.to_s =~ /password|private-key|token|auth-str|psk|^secret$/
   choices=CHOICES[path] || CHOICES[key.to_s]
   kind='choice' if choices
   info=desc[path.downcase] || desc[key.to_s.downcase] || ''
   field={'path'=>path,'title'=>path,'kind'=>kind,'hint'=>value.nil? ? '' : (value.is_a?(String) ? value : JSON.generate(value)), 'description'=>info,'required'=>false}
   # YAML samples are examples, not defaults. Only explicit documentation defaults become placeholders.
   if !%w[boolean list map secret].include?(kind)
    default = if kind == 'choice'
     info.match(/默认(?:值)?(?:为|使用)?\s*([A-Za-z0-9][A-Za-z0-9_.:\/-]*)(?=[，。；、\s(（]|$)/)
    else
     info.match(/默认(?:值)?(?:为|使用)\s*([A-Za-z0-9][A-Za-z0-9_.:\/-]*)(?=[，。；、\s(（]|$)/)
    end
    default ||= info.match(/默认\s+(\d+)(?=[，。；、\s(（]|$)/)
    if default
     candidate = default[1]
     candidate = candidate.delete_prefix('v') if path == 'shadow-tls-opts.version'
     valid = (kind != 'integer' || candidate.match?(/\A-?\d+\z/)) && (kind != 'choice' || choices.include?(candidate))
     field['defaultHint'] = candidate if valid
    end
    field['defaultHint'] = 'clash.meta' if path == 'global-ua'
   end
   if kind == 'choice' && !field['defaultHint']
    choices.each do |choice|
     if info.match?(/(?:^|[\s,，])#{Regexp.escape(choice)}:[^。；]*?默认值/)
      field['defaultHint'] = choice
      break
     end
    end
   end
   field['choices']=choices if choices
   if kind=='list'
    field['elementKind'] = value.first.is_a?(Hash) ? 'object' : value.all? { |v| v.is_a?(Integer) } && !value.empty? ? 'integer' : 'string'
    field['children']=fields(value.first,'',desc) if value.first.is_a?(Hash)
   elsif kind=='map'
    field['elementKind'] = value.values.any? { |v| v.is_a?(Array) } ? 'list' : 'string'
   end
   [field]
  end
 end
end
sections=[]
[['general.md','全局配置',''],['dns/index.md','DNS','dns'],['sniff/index.md','域名嗅探','sniffer'],['inbound/tun.md','TUN','tun']].each do |file,title,prefix|
 $doc_label=file; text=File.read(File.join(root,file)); values={}
 samples(text).each { |s| merge(values,s) }
 if prefix==''
  samples(File.read(File.join(root,'inbound/port.md'))).each { |s| merge(values,s) }
 elsif prefix=='tun'
  values['tun']['congestion-controller']='cubic'
 end
 if prefix=='dns'
  samples(File.read(File.join(root,'dns/hosts.md'))).each { |sample| merge(values,sample) }
 end
 desc=descriptions(text)
 if prefix!=''
  desc=desc.transform_keys { |k| k.start_with?(prefix+'.') ? k : prefix+'.'+k }
 end
 fs=fields(values,'',desc)
 # Explicit defaults stated under Chinese headings in general.md.
 if prefix == ''
  {'mode'=>'rule', 'find-process-mode'=>'strict', 'geodata-loader'=>'memconservative'}.each do |path, default|
   field = fs.find { |item| item['path'] == path }
   field['defaultHint'] = default if field && field['choices'].include?(default)
  end
 end
 # Keep all platform-specific options visible; only documented restrictions disable editing on macOS.
 linux_fields = %w[tproxy-port routing-mark external-controller-routing-mark tun.auto-redirect
  tun.gso tun.gso-max-size tun.iproute2-table-index tun.iproute2-rule-index
  tun.route-address-set tun.route-exclude-address-set tun.include-uid tun.include-uid-range
  tun.exclude-uid tun.exclude-uid-range tun.include-mac-address tun.exclude-mac-address]
 android_fields = %w[tun.include-android-user tun.include-package tun.exclude-package]
 fs.each do |field|
  platform = if field['path'] == 'tproxy-port' then 'Linux / Android'
   elsif linux_fields.include?(field['path']) then 'Linux'
   elsif android_fields.include?(field['path']) then 'Android'
   elsif field['path'] == 'external-controller-pipe' then 'Windows'
   end
  field['unavailableReason'] = "仅支持 #{platform}" if platform
 end
 sections << {'name'=>title,'key'=>prefix.empty? ? 'general' : prefix,'fields'=>fs,'document'=>file}
end
common_text=File.read(File.join(root,'proxies/index.md'))
common=samples(common_text).first['proxies'].first
common.delete('type'); common.delete('routing-mark')
tls_text=File.read(File.join(root,'proxies/tls.md')); tls=samples(tls_text).first['proxies'].first
tls.delete('name'); tls.delete('tlsmirror-opts')
transport_text=File.read(File.join(root,'proxies/transport.md')); transport={}
samples(transport_text).each { |s| merge(transport,s['proxies'].first) if s['proxies'].is_a?(Array) }
transport.select! { |key,value| %w[ws-opts http-opts h2-opts grpc-opts].include?(key) }
proxy_schemas=[]
Dir.glob(File.join(root,'proxies/*.md')).reject { |p| p =~ /\.(en|ru)\.md$/ || %w[index.md tls.md transport.md built-in.md dialer-proxy.md].include?(File.basename(p)) }.sort.each do |file|
 $doc_label=File.basename(file); text=File.read(file); values={}; kind=nil
 samples(text).each do |sample|
  next unless sample['proxies'].is_a?(Array)
  sample['proxies'].each do |proxy|
   next unless proxy.is_a?(Hash) && proxy['type']
   kind ||= proxy['type']
   merge(values,proxy) if proxy['type']==kind
  end
 end
 next unless kind
 supports_network=%w[vmess vless trojan].include?(kind)
 supports_tls=text.include?('./tls.md') || values.key?('tls') || values.key?('sni') || values.key?('servername')
 base=common.dup
 if %w[direct dns rematch tailscale zerotier easytier openvpn].include?(kind)
  base.delete('server'); base.delete('port')
 end
 merge(base,tls) if supports_tls
 merge(base,transport) if supports_network
 merge(base,values)
 base.delete('type')
 base.delete('reality-opts') unless %w[vmess vless trojan].include?(kind)
 base.delete('client-fingerprint') unless %w[vmess vless trojan anytls trusttunnel snell].include?(kind)
 if %w[hysteria hysteria2 tuic shadowquic wireguard masque zerotier].include?(kind)
  %w[tfo mptcp smux shadow-tls-opts restls-opts jls-opts ech-opts].each { |key| base.delete(key) }
 end
 base.delete('tls') if %w[hysteria hysteria2 trojan tuic anytls trusttunnel shadowquic].include?(kind)
 if %w[vmess vless].include?(kind)
  base.delete('sni')
 else
  base.delete('servername')
 end
 base['headers']={} if kind=='http'
 fs=fields(base,'',descriptions(common_text).merge(descriptions(tls_text)).merge(descriptions(transport_text)).merge(descriptions(text)))
 required=%w[name]
 required += %w[server port] if base.key?('server') && !%w[wireguard].include?(kind)
 required += case kind
  when 'hysteria2','trojan','anytls' then %w[password]
  when 'ss' then %w[cipher password]
  when 'ssr' then %w[cipher password protocol obfs]
  when 'vmess','vless' then %w[uuid]
  when 'snell' then %w[psk]
  when 'mieru','shadowquic','trusttunnel' then %w[username password]
  when 'ssh' then %w[username]
  else []
 end
 fs.each do |f|
  f['required']=required.include?(f['path'])
  f.delete('defaultHint') if f['required']
  if f['path']=='obfs' && kind=='hysteria2'; f['kind']='choice';f['choices']=%w[salamander gecko]; end
  if f['path']=='transport' && kind=='mieru'; f['kind']='choice';f['choices']=%w[TCP UDP]; end
  if f['path']=='cipher' && kind=='vmess'; f['kind']='choice';f['choices']=%w[auto aes-128-gcm chacha20-poly1305 none zero]; end
  f['kind']='string' if f['path']=='hop-interval' && kind=='hysteria2'
 end
 fs.sort_by! { |f| [%w[name server port].index(f['path']) || (f['required'] ? 3 : 4),f['path']] }
 proxy_schemas << {'name'=>kind,'key'=>kind,'fields'=>fs,'document'=>'proxies/'+File.basename(file)}
end
# Display order from https://github.com/MetaCubeX/mihomo/blob/Meta/docs/config.yaml,
# including commented keys. Unlisted fields follow their listed siblings.
configuration_order = %w[
 port
 socks-port
 redir-port
 tproxy-port
 mixed-port
 allow-lan
 bind-address
 authentication
 skip-auth-prefixes
 lan-allowed-ips
 lan-disallowed-ips
 find-process-mode
 mode
 geox-url
 geox-url.geoip
 geox-url.geosite
 geox-url.mmdb
 geo-auto-update
 geo-update-interval
 log-level
 ipv6
 tls
 tls.certificate
 tls.private-key
 tls.ech-key
 external-controller
 external-controller-tls
 secret
 external-controller-cors
 external-controller-cors.allow-origins
 external-controller-cors.allow-private-network
 external-controller-unix
 tcp-concurrent
 external-ui
 external-ui-name
 external-ui-url
 external-doh-server
 interface-name
 disable-keep-alive
 keep-alive-idle
 keep-alive-interval
 hosts
 profile
 profile.store-selected
 profile.store-fake-ip
 tun
 tun.enable
 tun.stack
 tun.dns-hijack
 tun.auto-detect-interface
 tun.auto-route
 tun.mtu
 tun.gso
 tun.gso-max-size
 tun.strict-route
 tun.congestion-controller
 tun.route-address
 tun.endpoint-independent-nat
 tun.include-interface
 tun.exclude-interface
 sniffer
 sniffer.enable
 sniffer.force-dns-mapping
 sniffer.parse-pure-ip
 sniffer.override-destination
 sniffer.sniff
 sniffer.sniff.QUIC
 sniffer.sniff.QUIC.ports
 sniffer.sniff.TLS
 sniffer.sniff.TLS.ports
 sniffer.sniff.HTTP
 sniffer.sniff.HTTP.ports
 sniffer.sniff.HTTP.override-destination
 sniffer.force-domain
 sniffer.skip-src-address
 sniffer.skip-dst-address
 sniffer.skip-domain
 dns
 dns.cache-algorithm
 dns.enable
 dns.prefer-h3
 dns.listen
 dns.ipv6
 dns.default-nameserver
 dns.enhanced-mode
 dns.fake-ip-range
 dns.fake-ip-range6
 dns.fake-ip-filter
 dns.fake-ip-filter-mode
 dns.fake-ip-ttl
 dns.use-hosts
 dns.respect-rules
 dns.nameserver
 dns.fallback
 dns.proxy-server-nameserver
 dns.proxy-server-nameserver-policy
 dns.direct-nameserver
 dns.direct-nameserver-follow-policy
 dns.fallback-filter
 dns.fallback-filter.geoip
 dns.fallback-filter.geoip-code
 dns.fallback-filter.ipcidr
 dns.fallback-filter.domain
 dns.fallback-filter.geosite
 dns.fallback-lazy-query
 dns.nameserver-policy
]
ranks = configuration_order.each_with_index.to_h
# These options have dedicated editors elsewhere in the app. Keep schema/validation data,
# but do not duplicate their controls on the global configuration page.
dedicated_editor_keys = %w[proxies proxy-providers proxy-groups rule-providers rules]
configuration_fields = sections.flat_map do |section|
 section['fields'].reject { |field| dedicated_editor_keys.include?(field['path'].split('.').first) }.map { |field| field.merge('document'=>section['document'], 'title'=>field['path'].split('.').last) }
end
def configuration_tree(fields, ranks, prefix='')
 keys = fields.map { |field| field['path'].delete_prefix(prefix).split('.').first }.uniq
 keys.each_with_index.sort_by { |key,index| [ranks.fetch(prefix+key, Float::INFINITY),index] }.map do |key,index|
  path = prefix + key
  field = fields.find { |item| item['path'] == path }
  next field if field
  children = fields.select { |item| item['path'].start_with?(path+'.') }
  {'path'=>path, 'title'=>key, 'kind'=>'group', 'hint'=>'', 'description'=>'', 'required'=>false,
   'children'=>configuration_tree(children, ranks, path+'.')}
 end
end
configuration = configuration_tree(configuration_fields, ranks)
payload={'sections'=>sections,'proxies'=>proxy_schemas,'configuration'=>configuration}
json=JSON.pretty_generate(payload)
File.write('Sources/ClashCore/DocSchemas.swift',"// Generated from Meta-Docs config documentation by scripts/build-schema.rb.\nimport Foundation\n\nlet docSchemaJSON = #\"\"\"\n#{json}\n\"\"\"#\n")
puts "Generated #{sections.sum { |s| s['fields'].length }} configuration fields and #{proxy_schemas.length} proxy types: #{proxy_schemas.map { |s| s['key'] }.join(', ')}"
