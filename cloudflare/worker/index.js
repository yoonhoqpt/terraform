/****************************************
 * CONFIGURATION
 ****************************************/

// toggle Shape functionality on/off
// use 'true' for enabled, use 'false' for disabled
const SHAPE_ENABLED = 'true'

// location of Shape's client-side Javascript
// must NOT begin with /cdn-cgi, as these paths are intercepted by CF
const CLIENT_LOCATION = '/js/dl_grxvucqw9h.js'

// comma delimited list of paths that should include Shape's client-side Javascript
// you may use asterisk (*) as a wildcard in your paths
const ENTRY_PATHS = '/*'

// comma delimited list of paths for Shape to protect
// you may use asterisk (*) as a wildcard in your paths
const PROTECTED_PATHS = '/marketplace/graphql*'

/****************************************
 * WORKER LOGIC
 ****************************************/

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(originalRequest) {
  let forwardedRequest = new Request(originalRequest, { cf: {} })

  // if the request is to a (protected_path OR to a client_location) AND it is not coming from Shape.
  // change the destination to Shape
  if (shouldForwardToShape(forwardedRequest)) {
    let newURL = new URL(originalRequest.url)
    newURL.hostname = SHAPE_LOAD_BALANCER
    forwardedRequest = new Request(newURL.toString(), forwardedRequest)
  }
  // if request is comming from shape, set the real ip to be from Shape.
  else if (shouldRewriteIP(forwardedRequest)) {
    let ip = getIPFromShapeHeader(forwardedRequest)
    if (ip) {
      // CF will copy X-Real-IP into CF-Connecting-IP before forwarding to origin
      forwardedRequest.headers.set('X-Real-IP', ip)
    }
  }

  // Send the request to either Shape or Project BE
  let originalResponse = await fetch(forwardedRequest)

  let forwardedResponse = new Response(originalResponse.body, originalResponse)

  // If the request is asking for the Shape Javascript Library and it was not found, burst the cache
  if (shouldRewriteResponse(forwardedRequest, forwardedResponse)) {
    caches.default.delete(forwardedRequest)
    let emptyResponse = new Response()
    emptyResponse.headers.set('Cache-Control', 'no-cache, no-store, must-revalidate')
    return emptyResponse
  }
  // If the request is for one of the pages we wish to monitor with Shape, inject the Shape JS client library.
  else if (shouldInjectClient(forwardedRequest, forwardedResponse)) {
    forwardedResponse = injectShapeClientExactlyOnce(forwardedResponse)
  }

  // add a nonce to page elements in the response (including the ShapeJS script) so that browsers can accept it.
  return await rewrite_nonce(forwardedRequest, forwardedResponse)
}

function shouldForwardToShape(request) {
  return isShapeEnabled() &&
    (foundPathMatchInRegexList(request, PROTECTED_PATHS_LIST) || foundPathMatchInRegexList(request, CLIENT_PATHS_LIST)) &&
    !hasSeenShape(request)
}

function shouldRewriteIP(request) {
  return isShapeEnabled() &&
    hasSeenShape(request)
}

function shouldInjectClient(request, response) {
  return isShapeEnabled() &&
    foundPathMatchInRegexList(request, ENTRY_PATHS_LIST) &&
    !hasInterstitialHeader(response)
}

function shouldRewriteResponse(request, response) {
  return isShapeEnabled() &&
    foundPathMatchInRegexList(request, CLIENT_PATHS_LIST) &&
    response.status == 404
}

function getIPFromShapeHeader(request) {
  return request.headers.get('X-SHAPE-CLIENT-IP')
}

function getIPFromCloudflareHeader(request) {
  return request.headers.get('CF-Connecting-IP')
}

function isShapeEnabled() {
  return equalsIgnoreCase(SHAPE_ENABLED, 'true')
}

function hasSeenShape(request) {
  return foundIPMatchInRegexList(request, SHAPE_IPS_LIST) &&
    hasShapeHeader(request)
}

function hasShapeHeader(request) {
  return equalsIgnoreCase(request.headers.get('SHAPE-HEADER'), 'true')
}

function hasInterstitialHeader(response) {
  return equalsIgnoreCase(response.headers.get('ISTL-RESPONSE'), '1')
}

function foundPathMatchInRegexList(request, list) {
  let path = new URL(request.url).pathname
  let match = list.find(regex => regex.test(path))
  return !!match
}

function foundIPMatchInRegexList(request, list) {
  let ip = getIPFromCloudflareHeader(request)
  let match = list.find(regex => regex.test(ip))
  return !!match
}

function equalsIgnoreCase(str1, str2) {
  return str2.localeCompare(str1, undefined, { sensitivity: 'base' }) === 0
}

const CLIENT_REMOVER = new HTMLRewriter()
  .on('script[src^="' + CLIENT_LOCATION + '"]', { element: e => e.remove() })

const CLIENT_INJECTOR = new HTMLRewriter()
  .on('head', { element: e => prependShapeClientTags(e) })

function prependShapeClientTags(element) {
  element
    .prepend('<script src="' + CLIENT_LOCATION + '"></script>', { html: true })
}

function injectShapeClientExactlyOnce(response) {
  let cleanResponse = CLIENT_REMOVER.transform(response)
  let injectedResponse = CLIENT_INJECTOR.transform(cleanResponse)
  return injectedResponse
}

const SHAPE_IPS_LIST = convertWildcardsToRegexList(SHAPE_IPS)
const PROTECTED_PATHS_LIST = convertWildcardsToRegexList(PROTECTED_PATHS)
const CLIENT_PATHS_LIST = convertWildcardsToRegexList(CLIENT_LOCATION)
const ENTRY_PATHS_LIST = convertWildcardsToRegexList(ENTRY_PATHS)

function convertWildcardsToRegexList(...strs) {
  return strs
    .map(convertWildcardToRegexList)
    .flat()
}

function convertWildcardToRegexList(str) {
  return str
    .split(/,\s*/)
    .filter(e => e)
    .map(convertWildcardToRegex)
}

function convertWildcardToRegex(str) {
  return new RegExp("^" + str.split("*").map(escapeRegex).join(".*") + "$")
}

function escapeRegex(str) {
  return str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1")
}


/*
NONCE REWRITER
*/

async function rewrite_nonce(request, oldResponse) {

  // Generate a nonce
  const bytes = crypto.getRandomValues(new Uint8Array(32))
  const nonce = btoa(bytes.toString())

  // Rewrite all script tags to include a nonce attribute
  // and transform old response to new response
  const newResponse = new HTMLRewriter()
    // Add nonce to head tag
    .on('head', {
      element(element) {
        element.setAttribute('nonce', nonce)
      },
    })
    // Add nonce to next.js generated script tags
    .on('script[src^="/_next/static"]', {
      element(element) {
        element.setAttribute('nonce', nonce)
      },
    })
    // Add nonce to next.js generated link tags
    .on('link[href^="/_next/static"]', {
      element(element) {
        element.setAttribute('nonce', nonce)
      },
    })
    // Add nonce to the injected Shape JS script
    .on('script[src^="/js/dl_"]', {
      element(element) {
        element.setAttribute('nonce', nonce)
      },
    })
    // Add nonce to storybook scripts
    // .on('script', {
    //   element(element) {
    //     if (request.url.includes('/storybook')) {
    //       element.setAttribute('nonce', nonce)
    //     }
    //   },
    // })
    // This attribute value matches what's set in the app. We
    // use something hard-to-guess to add an extra layer of
    // security. After setting the nonce attribute, we remove
    // the original data-nonce attribute so users never know
    // about it.
    .on('*[data-nonce="bfe1b8c8-4852-4886-8e91-d914542f680b"]', {
      element(element) {
        element.setAttribute('nonce', nonce)
        element.removeAttribute('data-nonce')
      },
    })
    .transform(oldResponse)

  // Add a CSP headers including generated nonce
  newResponse.headers.set(
    'Content-Security-Policy',
    `script-src 'nonce-${nonce}' 'self' 'strict-dynamic' 'unsafe-inline' https:`
  )

  // If review or staging env and req url includes storybook path, just ignore
  // the nonce and strict-dynamic on the csp and return old response
  if (
    (ENVIRONMENT === 'review' || ENVIRONMENT === 'staging') &&
    request.url.includes('/storybook')
  ) {
    oldResponse.headers.set(
      'Content-Security-Policy',
      `script-src 'self' 'unsafe-inline' https:`
    );
    return oldResponse
  }

  return newResponse
}
