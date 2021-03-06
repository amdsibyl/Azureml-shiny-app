#===========================================================================
# Library
#===========================================================================
library(shiny)
library(bitops)
library(RCurl)
library(rjson)

#===========================================================================
# Server
#===========================================================================
function(input, output) {
  #==== Get UI.R's input ====
  Ui_input <- reactive({ ###### Check 1 ######
   return( list( 
     'PassengerId' = "1",
     'Survived' = "1",
     'Pclass' = input$PassengerClass,
     'Name' = "",
     'Sex' = input$Gender ,
     'Age' = as.character(input$Age),
     'SibSp' = as.character(input$SiblingSpouse) ,
     'Parch' = as.character(input$ParentChild),
     'Ticket' = "",
     'Fare' = "1",
     'Cabin' = "",
     'Embarked' = input$PortEmbarkation
     
     ) )
  })
  
  #==== Output : Prediction ====   
  output$result_plot <- renderImage({
    #---- Connect to Azure ML workspace ----  
    options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
    # Accept SSL certificates issued by public Certificate Authorities
    
    h = basicTextGatherer()
    hdr = basicHeaderGatherer()
    
    #---- Put input_data to Azure ML workspace ----
    req = list(
      Inputs = list(
        "input1" = list(
          Ui_input()
        )
      ),
      GlobalParameters = setNames(fromJSON('{}'), character(0))
    )
    
    #---- Web service : API key ----
    body = enc2utf8(toJSON(req))
    api_key = "I62mqmqZjyrLmhDz+4oIBaL8zWQ8lTgafqc7BmuitXJzsvbabJ7fosPqxe1q6CTzR7ZFMIVX+sLrgxM0KitlUA=="  ###### Check 2 ######
    authz_hdr = paste('Bearer', api_key, sep=' ')
    
    h$reset()
    curlPerform(url = "https://ussouthcentral.services.azureml.net/workspaces/32f145a079c7420aa12b37e1a96718ee/services/133b02900d1d49258e6419424998c2c1/execute?api-version=2.0&format=swagger",   ###### Check 3 ######
                httpheader=c('Content-Type' = "application/json", 'Authorization' = authz_hdr),
                postfields=body,
                writefunction = h$update,
                headerfunction = hdr$update,
                verbose = TRUE
    )
    
    #---- Get Result  ----
    #result = fromJSON( h$value() )$Results$output2[[1]]$PredictedSurvived   ###### Check 4 ######
    result = fromJSON(h$value())$Results$output1[[1]]$predict
    if ( result == "1") {
      return( list(
        src = "www/survived.png",
        height = 480, width = 700,
        alt = "Survived"
      ))
    }else if ( result == "0") {
      return(list(
        src = "www/deceased.png",
        height = 480, width = 700,
        alt = "Deceased"
      ))
    }
  }, deleteFile = FALSE)
}
