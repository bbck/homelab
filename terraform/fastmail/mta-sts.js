const policy = `version: STSv1
mode: enforce
mx: in1-smtp.messagingengine.com
mx: in2-smtp.messagingengine.com
max_age: 604800`;

async function handleRequest(request) {
  return new Response(policy, {
    headers: {
      'content-type': 'text/plain;charset=UTF-8',
    },
  });
}

addEventListener('fetch', event => {
  return event.respondWith(handleRequest(event.request));
});
