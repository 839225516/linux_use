listen {
  port = 4040
  address = "0.0.0.0"
}

enable_experimental=true

namespace "tengine" {
  format = "[$time_local] $remote_addr $server_addr:$server_port $upstream_addr \"$request\" [$request_length/$bytes_sent] \"$status\"  {$request_time/$upstream_response_time} \"$http_referer\" \"$host\" \"$http_user_agent\" $http_x_forwarded_for"
  source_files = [
    "/data/prometheusNginx/access.log"
  ]
  labels {
    app = "10.0.120.16"
  }
  relabel "serviceport" {
     from = "server_port"
  }
  relabel "upstream_addr" {
     from = "upstream_addr"
  } 
  relabel  "request_uri" {
     from = "request"
     split = 2
  }
}
