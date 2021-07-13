# R sms library to send sms with http/rest/json

This R sms library enables you to **send** and **receive** SMS from R with http requests. The library uses HTTP Post requests and JSON encoded content to send the text messages to the mobile network1. It connects to the HTTP SMS API of [Ozeki SMS gateway](https://ozeki-sms-gateway.com).

# What is Ozeki SMS Gateway?

Ozeki SMS Gateway is a powerful SMS Gateway software you can download and install on your Windows or Linux computer or to your Android mobile phone. It provides an HTTP SMS API, that allows you to connect to it from local or remote programs. The reason why companies use Ozeki SMS Gateway as their first point of access to the mobile network, is because it provides service provider independence. When you use Ozeki, the SMS contact lists and sms data is safe, because Ozeki is installed in their own computer (physical or virtual), and Ozeki provides direct access to the mobile network through wireless connections

Download: [Ozeki SMS Gateway download page](https://ozeki-sms-gateway.com/p_727-download-sms-gateway.html)

Tutorial: [R send sms sample and tutorial](https://ozeki-sms-gateway.com/p_876-r-send-sms-with-the-http-rest-api-code-sample.html)

# How to send sms from R:

**To send sms from R**
1. [Download Ozeki SMS Gateway](https://ozeki-sms-gateway.com/p_727-download-sms-gateway.html)
2. [Connect Ozeki SMS Gateway to the mobile network](https://ozeki-sms-gateway.com/p_70-mobile-network.html)
3. [Create an HTTP SMS API user](https://ozeki-sms-gateway.com/p_2102-create-an-http-sms-api-user-account.html)
4. Checkout the Github send SMS from R repository
5. Open the Github SMS send example in Visual Studio
6. Compile the Send SMS console project
7. Check the logs in Ozeki SMS Gateway


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

## Manual / API reference
To get a better understanding of the above **SMS code sample**, it is a good idea to visit the webpage that explains this code in a more detailed way. You can find videos, explanations and downloadable content on this URL.

Link: [How to send sms from R](https://ozeki-sms-gateway.com/p_876-r-send-sms-with-the-http-rest-api-code-sample.html)


## Get started now

Don't waste your time, start using the repository now!
