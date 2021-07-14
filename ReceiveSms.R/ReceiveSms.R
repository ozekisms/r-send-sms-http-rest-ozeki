library(Ozeki.Libs.Rest)


configuration <- Ozeki.Libs.Rest::Configuration$new(
  username = "http_user",
  password = "qwe123",
  api_url = "http://127.0.0.1:9509/api"
)

api <- Ozeki.Libs.Rest::MessageApi$new(configuration)

result <- api$download_incoming()

print(result$to_string())

for (message in result$messages) {
  print(message$to_string())
}
