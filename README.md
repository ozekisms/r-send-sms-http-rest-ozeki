# Ozeki.Libs.Rest library for R

In order to download the Ozeki.Libs.Rest library, firstly you have to install the devtools library with the following command:

```r
 $ r
 $ install.packages("devtools")
```

After you have installed the devtools, you can install the Ozeki.Libs.Rest library by using the install_github function:

```
 $ install_github('ozekisms/r-send-sms-http-rest-ozeki')
```

Include the freshly installed Ozeki.Libs.Rest library:

```
library(Ozeki.Libs.Rest)
```

First of all you have to create a configuration file by using the Configuration class of the Ozeki.Libs.Rest library:

```r
configuration <- Ozeki.Libs.Rest::Configuration$new(
  username = "http_user",
  password = "qwe123",
  api_url = "http://127.0.0.1:9509/api"
)
```

Then you can create the message you want to send by creating a Message instance:

```r
msg <- Ozeki.Libs.Rest::Message$new()
msg$to_address <- "+36201111111"
msg$text <- "Hello world!"
```

After you have created the configuration, and the message objects, you can continue by creating a message api using the MessageApi class of the Ozeki.Libs.Rest library.

```r
api <- Ozeki.Libs.Rest::MessageApi$new(configuration)
```

After everything is ready, you can send the sms message with the send method of the MessageaApi object:

```r
result <- api$send(msg)
```
