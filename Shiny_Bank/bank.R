library("RCurl")
library("rjson")

# Accept SSL certificates issued by public Certificate Authorities
options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))

h = basicTextGatherer()
hdr = basicHeaderGatherer()

req =  list(
  Inputs = list(
    "input1"= list(
      list(
        'age' = "20",
        'job' = "blue-collar",
        'marital' = "married",
        'education' = "basic.9y",
        'default' = "no",
        'housing' = "yes",
        'loan' = "no",
        'campaign' = "2",
        'poutcome' = "nonexistent",
        'y' = "no"
      )
    )
  ),
  GlobalParameters = setNames(fromJSON('{}'), character(0))
)

body = enc2utf8(toJSON(req))
api_key = "DJUGlYjo7EQ1wh0EN0MCbZ4KoEkbuwDjdjFTccWt/I+bxFHCSu/ow3sZ4nNk36z1Zp9rx9oGkIlX0kS+ak5fRg==" # Replace this with the API key for the web service
authz_hdr = paste('Bearer', api_key, sep=' ')

h$reset()
curlPerform(url = "https://ussouthcentral.services.azureml.net/workspaces/32f145a079c7420aa12b37e1a96718ee/services/513753b318f948b4bdc5bce4c9edb2b5/execute?api-version=2.0&format=swagger",
            httpheader=c('Content-Type' = "application/json", 'Authorization' = authz_hdr),
            postfields=body,
            writefunction = h$update,
            headerfunction = hdr$update,
            verbose = TRUE
)

headers = hdr$value()
httpStatus = headers["status"]
if (httpStatus >= 400)
{
  print(paste("The request failed with status code:", httpStatus, sep=" "))
  
  # Print the headers - they include the requert ID and the timestamp, which are useful for debugging the failure
  print(headers)
}

print("Result:")
result = h$value()
print(fromJSON(result))