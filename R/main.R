library(uuid)
library(R6)
library(base64enc)
library(httr)
library(jsonlite)


Configuration <- R6Class(classname = "Configuraiton",
                         public = list (
                           username = NULL,
                           password = NULL,
                           api_url = NULL,
                           initialize = function (username = NA, password = NA, api_url = NA) {
                             self$username <- username
                             self$password <- password
                             self$api_url <- api_url
                           })
)

Message <- R6Class(classname = "Message",
                   public = list(
                     id = NULL,
                     from_connection = NULL,
                     from_address = NULL,
                     from_station = NULL,
                     to_connection = NULL,
                     to_address = NULL,
                     to_station = NULL,
                     text = NULL,
                     create_date = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS"),
                     valid_until = paste((as.Date(Sys.time()) + 7), "T", format(Sys.time(), "%H:%M:%OS"), sep = ""),
                     time_to_send = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS"),
                     is_submit_report_requested = TRUE,
                     is_delivery_report_requested = TRUE,
                     is_view_report_requested = TRUE,
                     tags = NULL,
                     initialize = function(id = uuid::UUIDgenerate(use.time = FALSE, n = 1L), from_connection = NULL, from_address = NULL, from_station = NULL, to_connection = NULL, to_address = NULL, to_station = NULL, text = NULL, time_to_send = self$create_date, is_submit_report_requested = TRUE, is_delivery_report_requested = TRUE, is_view_report_requested = TRUE) {
                       self$id <- id
                       self$from_connection <- from_connection
                       self$from_address <- from_address
                       self$from_station <- from_station
                       self$to_connection <- to_connection
                       self$to_address <- to_address
                       self$to_station <- to_station
                       self$text <- text
                       self$time_to_send = time_to_send
                       self$is_submit_report_requested = is_submit_report_requested
                       self$is_delivery_report_requested = is_delivery_report_requested
                       self$is_view_report_requested = is_view_report_requested
                       self$tags = c()
                     },
                     add_tag = function(key = NA, value = NA) {
                       self$tags[[length(self$tags)+1]] <- list(name=key, value=value)
                     },
                     get_tags = function() {
                       json <- "["
                       for (i in 1:length(self$tags)) {
                         tag <- paste('{"name":"', self$tags[[i]]$name, '","value":"', self$tags[[i]]$value, '"}', sep="")
                         if (json == "[") {
                           json <- paste(json, tag, sep="")
                         } else {
                           json <- paste(json, ',', tag, sep="")
                         }
                       }
                       json <- paste(json, "]", sep="")
                       return (json)
                     },
                     get_json = function() {
                       json <- "{"
                       json <- paste(json, '"message_id":', '"', self$id, '"', sep="")
                       if (!is.null(self$from_connection)) {
                         json <- paste(json, ',"from_connection":', '"', self$from_connection, '"', sep="")
                       }
                       if (!is.null(self$from_address)) {
                         json <- paste(json, ',"from_address":', '"', self$from_address, '"', sep="")
                       }
                       if (!is.null(self$from_station)) {
                         json <- paste(json, ',"from_station":', '"', self$from_station, '"', sep="")
                       }
                       if (!is.null(self$to_connection)) {
                         json <- paste(json, ',"to_connection":', '"', self$to_connection, '"', sep="")
                       }
                       if (!is.null(self$to_address)) {
                         json <- paste(json, ',"to_address":', '"', self$to_address, '"', sep="")
                       }
                       if (!is.null(self$to_station)) {
                         json <- paste(json, ',"to_station":', '"', self$to_station, '"', sep="")
                       }
                       if (!is.null(self$text)) {
                         json <- paste(json, ',"text":', '"', self$text, '"', sep="")
                       }
                       if (!is.null(self$create_date)) {
                         json <- paste(json, ',"create_date":', '"', self$create_date, '"', sep="")
                       }
                       if (!is.null(self$valid_until)) {
                         json <- paste(json, ',"valid_until":', '"', self$valid_until, '"', sep="")
                       }
                       if (!is.null(self$time_to_send)) {
                         json <- paste(json, ',"time_to_send":', '"', self$time_to_send, '"', sep="")
                       }
                       if (self$is_submit_report_requested) {
                         json <- paste(json, ',"is_submit_report_requested":', 'true', sep="")
                       } else {
                         json <- paste(json, ',"is_submit_report_requested":', 'false', sep="")
                       }
                       if (self$is_delivery_report_requested) {
                         json <- paste(json, ',"is_delivery_report_requested":', 'true', sep="")
                       } else {
                         json <- paste(json, ',"is_delivery_report_requested":', 'false', sep="")
                       }
                       if (self$is_view_report_requested) {
                         json <- paste(json, ',"is_view_report_requested":', 'true', sep="")
                       } else {
                         json <- paste(json, ',"is_view_report_requested":', 'false', sep="")
                       }
                       if (length(self$tags) != 0) {
                         json <- paste(json, ',"tags":', self$get_tags(), sep="")
                       }
                       json <- paste(json, "}", sep="")
                     },
                     to_string = function() {
                       return(paste(self$from_address, "->", self$to_address, " '", self$text, "'", sep=""))
                     }
                   )
)

MessageApi <- R6Class(classname="MessageApi",
                      public = list (
                        configuration = NULL,
                        initialize = function(configuration) {
                          self$configuration <- configuration
                        },
                        create_authorization_header = function (username, password) {
                          username_password <- paste(username, ":", password, sep="")
                          username_password_encoded <- base64enc::base64encode(charToRaw(username_password))
                          return (paste("Basic", username_password_encoded, sep=" "))
                        },
                        create_request_body = function(message = NA) {
                          json <- '{"messages":['
                          if (is.list(message)) {
                            for (element in message) {
                              if (json == '{"messages":[') {
                                json = paste(json, element$get_json(), sep="")
                              } else {
                                json = paste(json, ',', element$get_json(), sep="")
                              }
                            }
                          } else {
                            json = paste(json, message$get_json(), sep="")
                          }
                          json = paste(json, "]}", sep="")
                          return (json)
                        },
                        create_request_body_to_manipulate = function(folder = NA, message = NA) {
                          json <- paste('{"folder":"', folder, '","message_ids":[', sep="")
                          if (is.list(message)) {
                            counter <- 0
                            for (element in message) {
                              if (counter == 0) {
                                json = paste(json, '"', element$id, '"', sep="")
                                counter <- 1
                              } else {
                                json = paste(json, ', "', element$id, '"', sep="")
                              }
                            }
                          } else {
                            json = paste(json, '"', message$id, '"', sep="")
                          }
                          json = paste(json, "]}", sep="")
                          return (json)
                        },
                        send = function(message = NA) {
                          request_body = self$create_request_body(message)
                          authorization_header = self$create_authorization_header(self$configuration$username, self$configuration$password)
                          result <- self$get_response_send(self$do_request_post(url = self$create_uri_to_send_sms(self$configuration$api_url), request_body = request_body, authorization_header = authorization_header))
                          if (result$total_count == 1 && result$total_count == result$success_count) {
                            return(result$results[[1]])
                          } else {
                            return(result)
                          }
                        },
                        delete = function(folder = NA, message = NA) {
                          request_body = self$create_request_body_to_manipulate(folder, message)
                          authorization_header = self$create_authorization_header(self$configuration$username, self$configuration$password)
                          result <- self$get_response_delete(self$do_request_post(url = self$create_uri_to_delete_sms(self$configuration$api_url), request_body = request_body, authorization_header = authorization_header), message)
                          if (result$total_count == 1) {
                            if (result$total_count == result$success_count) {
                              return(TRUE)
                            } else {
                              return(FALSE)
                            }
                          } else {
                            return(result)
                          }
                        },
                        mark = function(folder = NA, message = NA) {
                          request_body = self$create_request_body_to_manipulate(folder, message)
                          authorization_header = self$create_authorization_header(self$configuration$username, self$configuration$password)
                          result <- self$get_response_mark(self$do_request_post(url = self$create_uri_to_mark_sms(self$configuration$api_url), request_body = request_body, authorization_header = authorization_header), message)
                          if (result$total_count == 1) {
                            if (result$total_count == result$success_count) {
                              return(TRUE)
                            } else {
                              return(FALSE)
                            }
                          } else {
                            return(result)
                          }
                        },
                        download_incoming = function() {
                          authorization_header = self$create_authorization_header(self$configuration$username, self$configuration$password)
                          result <- self$get_response_receive(self$do_request_get(url = self$create_uri_to_receive_sms(self$configuration$api_url, Folder$Inbox), authorization_header = authorization_header))
                          self$delete(Folder$Inbox, result$messages)
                          return(result)
                        },
                        do_request_post = function(url, request_body, authorization_header = NA) {
                          response <- httr::POST(url, httr::content_type_json(), body = request_body, httr::add_headers("Authorization" = authorization_header, "Content-Type" = "application/json", "Accept" = "application/json"))
                          result <- jsonlite::fromJSON(httr::content(response, as = "text"))
                        },
                        do_request_get = function(url, authorization_header = NA, message) {
                          response <- httr::GET(url, httr::add_headers("Authorization" = authorization_header, "Content-Type" = "application/json", "Accept" = "application/json"))
                          result <- jsonlite::fromJSON(httr::content(response, as = "text"))
                        },
                        create_uri_to_send_sms = function(url= NA) {
                          uri <- strsplit(url, "?", 1)
                          return(paste(uri[[1]][1], "?action=sendmsg", sep=""))
                        },
                        create_uri_to_delete_sms = function(url= NA) {
                          uri <- strsplit(url, "?", 1)
                          return(paste(uri[[1]][1], "?action=deletemsg", sep=""))
                        },
                        create_uri_to_mark_sms = function(url= NA) {
                          uri <- strsplit(url, "?", 1)
                          return(paste(uri[[1]][1], "?action=markmsg", sep=""))
                        },
                        create_uri_to_receive_sms = function(url = NA, folder = NA) {
                          uri <- strsplit(url, "?", 1)
                          return(paste(uri[[1]][1], "?action=receivemsg&folder=", folder, sep=""))
                        },
                        get_response_send = function(response = NA) {
                          result <- MessageSendResults$new()
                          result$total_count <- response$data$total_count
                          result$success_count <- response$data$success_count
                          result$failed_count <- response$data$failed_count
                          for (i in 1:nrow(response$data$messages)) {
                            message <- Message$new()
                            msg <- response$data$messages[i, ]
                            if ("message_id" %in% names(msg)) {
                              message$id = msg$message_id
                            }
                            if ("from_connection" %in% names(msg)) {
                              message$from_connection = msg$from_connection
                            }
                            if ("from_address" %in% names(msg)) {
                              message$from_address = msg$from_address
                            }
                            if ("from_station" %in% names(msg)) {
                              message$from_station = msg$from_station
                            }
                            if ("to_connection" %in% names(msg)) {
                              message$to_connection = msg$to_connection
                            }
                            if ("to_address" %in% names(msg)) {
                              message$to_address = msg$to_address
                            }
                            if ("to_station" %in% names(msg)) {
                              message$to_station = msg$to_station
                            }
                            if ("text" %in% names(msg)) {
                              message$text = msg$text
                            }
                            if ("create_date" %in% names(msg)) {
                              message$create_date = msg$create_date
                            }
                            if ("valid_until" %in% names(msg)) {
                              message$valid_until = msg$valid_until
                            }
                            if ("time_to_send" %in% names(msg)) {
                              message$time_to_send = msg$time_to_send
                            }
                            if ("submit_report_requested" %in% names(msg)) {
                              message$is_submit_report_requested = msg$submit_report_requested
                            }
                            if ("delivery_report_requested" %in% names(msg)) {
                              message$is_delivery_report_requested = msg$delivery_report_requested
                            }
                            if ("view_report_requested" %in% names(msg)) {
                              message$is_view_report_requested = msg$view_report_requested
                            }
                            if (length(msg$tags) > 0) {
                              for(tag in msg$tags) {
                                message$add_tag(tag$name, tag$value)
                              }
                            }
                            message_result = MessageSendResult$new(message, DeliveryStatus$Success, "")
                            result$add_result(message_result)
                          }
                          return (result)
                        },
                        get_response_delete = function(response = NA, message = NA) {
                          result <- MessageDeleteResult$new(response$data$folder)
                          if (is.list(message)) {
                            for (msg in message) {
                              success <- FALSE
                              for (id in response$data$message_ids) {
                                if (id == msg$id) {
                                  success <- TRUE
                                }
                              }
                              if (success) {
                                result$add_id_remove_succeeded(msg$id);
                              } else {
                                result$add_id_remove_failed(msg$id);
                              }
                            }
                          } else {
                            if (length(message) > 0) {
                              if (response$data$message_ids[1] == message$id) {
                                result$add_id_remove_succeeded(message$id);
                              } else {
                                result$add_id_remove_failed(message$id);
                              }
                            }
                          }
                          return (result)
                        },
                        get_response_mark = function(response = NA, message = NA) {
                          result <- MessageMarkResult$new(response$data$folder)
                          if (is.list(message)) {
                            for (msg in message) {
                              success <- FALSE
                              for (id in response$data$message_ids) {
                                if (id == msg$id) {
                                  success <- TRUE
                                }
                              }
                              if (success) {
                                result$add_id_mark_succeeded(msg$id);
                              } else {
                                result$add_id_mark_failed(msg$id);
                              }
                            }
                          } else {
                            if (length(message) > 0) {
                              if (!is.null(response$data$message_ids[1]) && response$data$message_ids[1] == message$id) {
                                result$add_id_mark_succeeded(message$id);
                              } else {
                                result$add_id_mark_failed(message$id);
                              }
                            }
                          }
                          return (result)
                        },
                        get_response_receive = function(response = NA) {
                          result = MessageReceiveResult$new(response$data$folder, response$data$limit)
                          if (length(response$data$data) > 0) {
                            for (i in 1:nrow(response$data$data)) {
                              message <- Message$new()
                              msg <- response$data$data[i, ]
                              if ("message_id" %in% names(msg)) {
                                message$id = msg$message_id
                              }
                              if ("from_connection" %in% names(msg)) {
                                message$from_connection = msg$from_connection
                              }
                              if ("from_address" %in% names(msg)) {
                                message$from_address = msg$from_address
                              }
                              if ("from_station" %in% names(msg)) {
                                message$from_station = msg$from_station
                              }
                              if ("to_connection" %in% names(msg)) {
                                message$to_connection = msg$to_connection
                              }
                              if ("to_address" %in% names(msg)) {
                                message$to_address = msg$to_address
                              }
                              if ("to_station" %in% names(msg)) {
                                message$to_station = msg$to_station
                              }
                              if ("text" %in% names(msg)) {
                                message$text = msg$text
                              }
                              if ("create_date" %in% names(msg)) {
                                message$create_date = msg$create_date
                              }
                              if ("valid_until" %in% names(msg)) {
                                message$valid_until = msg$valid_until
                              }
                              if ("time_to_send" %in% names(msg)) {
                                message$time_to_send = msg$time_to_send
                              }
                              if ("time_to_send" %in% names(msg)) {
                                message$time_to_send = msg$time_to_send
                              }
                              if ("submit_report_requested" %in% names(msg)) {
                                message$is_submit_report_requested = msg$submit_report_requested
                              }
                              if ("delivery_report_requested" %in% names(msg)) {
                                message$is_delivery_report_requested = msg$delivery_report_requested
                              }
                              if ("view_report_requested" %in% names(msg)) {
                                message$is_view_report_requested = msg$view_report_requested
                              }
                              if (length(msg$tags) > 0) {
                                for(i in 1:length(msg$tags)) {
                                  if (!is.null(msg$tags[[i]]$name) || !is.null(msg$tags[[i]]$value)) {
                                    message$add_tag(msg$tags[[i]]$name, msg$tags[[i]]$value)
                                  }
                                }
                              }
                              result$add_message(message)
                            }
                          }
                          return (result)
                        })
)

Folder <- list(Inbox = "inbox", Outbox = "outbox", Sent= "sent", NotSent = "notsent", Deleted = "deleted")

DeliveryStatus <- list(Success = "Success", Failed = "Failed")

MessageSendResults <- R6Class(classname="MessageSendResults",
                              public = list(
                                total_count = 0,
                                failed_count = 0,
                                success_count = 0,
                                results = c(),
                                add_result = function(result = NA) {
                                  self$results <- c(self$results, result)
                                },
                                to_string = function() {
                                  return(paste("Total: ", self$total_count, ". Success: ", self$success_count, ". Failed: ", self$failed_count, ".", sep=""))
                                }
                              ))

MessageSendResult <- R6Class(classname="MessageSendResult",
                             public = list(
                               message = NULL,
                               status = NULL,
                               response_msg = NULL,
                               initialize = function(message = NA, status = DeliveryStatus$Success, response_msg = "") {
                                 self$message = message
                                 self$status = status
                                 self$response_msg = response_msg
                               },
                               to_string = function() {
                                 return(paste(self$status, ", ", self$message$to_string(), sep=""))
                               }
                             ))

MessageDeleteResult <- R6Class(classname="MessageDeleteResult",
                               public = list(
                                 folder = NULL,
                                 message_ids_remove_succeeded = c(),
                                 message_ids_remove_failed = c(),
                                 total_count = 0,
                                 success_count = 0,
                                 failed_count = 0,
                                 initialize = function(folder = NA) {
                                   self$folder = folder
                                 },
                                 add_id_remove_succeeded = function(id = NA) {
                                   self$message_ids_remove_succeeded = c(self$message_ids_remove_succeeded, id)
                                   self$total_count <- self$total_count + 1
                                   self$success_count <- self$success_count + 1
                                 },
                                 add_id_remove_failed = function(id = NA) {
                                   self$message_ids_remove_failed = c(self$message_ids_remove_failed, id)
                                   self$total_count <- self$total_count + 1
                                   self$failed_count <- self$failed_count + 1
                                 },
                                 to_string = function() {
                                   return(paste("Total: ", self$total_count, ". Success: ", self$success_count, ". Failed: ", self$failed_count, ".", sep=""))
                                 }
                               ))

MessageMarkResult <- R6Class(classname="MessageMarkResult",
                             public = list(
                               folder = NULL,
                               message_ids_mark_succeeded = c(),
                               message_ids_mark_failed = c(),
                               total_count = 0,
                               success_count = 0,
                               failed_count = 0,
                               initialize = function(folder = NA) {
                                 self$folder = folder
                               },
                               add_id_mark_succeeded = function(id = NA) {
                                 self$message_ids_mark_succeeded = c(self$message_ids_mark_succeeded, id)
                                 self$total_count <- self$total_count + 1
                                 self$success_count <- self$success_count + 1
                               },
                               add_id_mark_failed = function(id = NA) {
                                 self$message_ids_mark_failed = c(self$message_ids_mark_failed, id)
                                 self$total_count <- self$total_count + 1
                                 self$failed_count <- self$failed_count + 1
                               },
                               to_string = function() {
                                 return(paste("Total: ", self$total_count, ". Success: ", self$success_count, ". Failed: ", self$failed_count, ".", sep=""))
                               }
                             ))

MessageReceiveResult <- R6Class(classname = "MessageReceiveResult",
                                public = list(
                                  folder = NULL,
                                  limit = NULL,
                                  messages = c(),
                                  initialize = function(folder = NA, limit = NA) {
                                    self$folder = folder
                                    self$limit = limit
                                  },
                                  add_message = function(message = NA) {
                                    self$messages <- c(self$messages, message)
                                  },
                                  to_string = function() {
                                    return(paste("Message count: ", length(self$messages), ".", sep=""))
                                  }
                                ))
