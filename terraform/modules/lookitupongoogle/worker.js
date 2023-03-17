export default {
  async fetch(request) {
    const base = 'https://www.google.com';
    const statusCode = 301;

    const url = new URL(request.url);
    const { pathname, search } = url;

    const destinationURL = `${base}${pathname}${search}`;
    console.log(destinationURL)

    return Response.redirect(destinationURL, statusCode);
  },
};
