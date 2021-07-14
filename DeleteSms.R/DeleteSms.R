library(Ozeki.Libs.Rest)


configuration <- Ozeki.Libs.Rest::Configuration$new(
  username = "http_user",
  password = "qwe123",
  api_url = "http://127.0.0.1:9509/api"
)

msg <- Ozeki.Libs.Rest::Message$new()
msg$id <- "c2f9d31b-d8ee-4304-a173-9d088b5c015d"

api <- Ozeki.Libs.Rest::MessageApi$new(configuration)

result <- api$delete(Ozeki.Libs.Rest::Folder$Inbox, msg)

print(result)
