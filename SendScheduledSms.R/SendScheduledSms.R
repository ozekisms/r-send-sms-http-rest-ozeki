library(Ozeki.Libs.Rest)


configuration <- Ozeki.Libs.Rest::Configuration$new(
  username = "http_user",
  password = "qwe123",
  api_url = "http://127.0.0.1:9509/api"
)

msg <- Ozeki.Libs.Rest::Message$new()
msg$to_address <- "+36201111111"
msg$text <- "Hello world!"
msg$time_to_send <- "2021-07-13T14:00:00"

api <- Ozeki.Libs.Rest::MessageApi$new(configuration)

result <- api$send(msg)

print(result$to_string())
