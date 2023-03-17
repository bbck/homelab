export default {
  async fetch(request) {
    const destinationURL = 'https://twitch.tv/56bagels';
    const statusCode = 301;
    return Response.redirect(destinationURL, statusCode);
  },
};
