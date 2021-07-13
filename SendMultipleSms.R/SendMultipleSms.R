library(Ozeki.Libs.Rest)


configuration <- Ozeki.Libs.Rest::Configuration$new(
  username = "http_user",
  password = "qwe123",
  api_url = "http://127.0.0.1:9509/api"
)

msg1 <- Ozeki.Libs.Rest::Message$new()
msg1$to_address <- "+36201111111"
msg1$text <- "Hello world 1"

msg2 <- Ozeki.Libs.Rest::Message$new()
msg2$to_address <- "+36202222222"
msg2$text <- "Hello world 2"

msg3 <- Ozeki.Libs.Rest::Message$new()
msg3$to_address <- "+36203333333"
msg3$text <- "Hello world 3"

api <- Ozeki.Libs.Rest::MessageApi$new(configuration)

result <- api$send(list(msg1, msg2, msg3))

print(result$to_string())
