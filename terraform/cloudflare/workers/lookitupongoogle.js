const base = 'https://www.google.com'
const statusCode = 301

async function handleRequest (request) {
  const url = new URL(request.url)
  const { pathname, search } = url

  const destinationURL = base + pathname + search

  return Response.redirect(destinationURL, statusCode)
}

addEventListener('fetch', async event => {
  event.respondWith(handleRequest(event.request))
})
