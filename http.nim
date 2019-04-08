import httpclient, json, strformat, asyncdispatch, uri

# https://forum.nim-lang.org/t/2262
# https://github.com/nim-lang/Nim/commit/5a007a84fc8350a3a43ddc712c7a59a9ab2dce79#diff-e7d29941cb2ca6bf4e0f5c627239bc7b

const base_url = "https://www.googleapis.com/books/v1/volumes?q="

type
  Author* = object
   name*, uri*, count*: string

proc fetch(uri: string): Future[string] =
  echo fmt"Fetching: {uri}"
  var client = newAsyncHttpClient()
  result = client.getContent(uri) 

proc getAuthorsResults(authors: JsonNode) {.async.} =
  var authorsSeq = newSeq[Author](0) # empty at creation
  var lookups = newSeq[Future[string]](0)

  for authorJSON in authors:
    let author = authorJSON.getStr()
    let author_url = fmt"{base_url}inauthor:{encodeUrl(author)}"
    authorsSeq.add(Author(name: author, uri: author_url))
    lookups.add(fetch(author_url))
  
  var allResults =  await all(lookups)
  var c = 0
  for res in allResults:
    var rj = parseJson(res)
    var count = rj["totalItems"]
    echo fmt" {authorsSeq[c].name} - {count}"
    c.inc()


proc main() {.async.} =

  const msa_isbn = "1491956224"
  let   msa_url = fmt"{base_url}isbn:{msa_isbn}" # "Microservice Architecture"
  let response = await fetch(msa_url)

  let rj = parseJson(response)
  let authors = rj["items"][0]["volumeInfo"]["authors"]

  await getAuthorsResults(authors)


waitFor main()

# compile with:
# nim compile -d:ssl http.nim