# frontend-worker

Cloudflare worker script that intercepts app requests and does the following:

## Shape Defense integration

Reroutes requests to certain paths to Shape for bot-defence analysis. Any other requests are sent to project backend as usual.

## Nonce Rewriter
Adds a nonce to specific HTML elements of the page, like script tags, so that the site is protected by content security policy.

- Generates a nonce on each request
- adds the nonce to the following tags:
  - `head` tag
  - any `script` tag that matches `script[src^="/_next/static"]`
  - any `link` tag that matches `link[href^="/_next/static"]`
  - any tag that has data attribute `data-nonce="bfe1b8c8-4852-4886-8e91-d914542f680b"` set on it
- updates the content security policy to pass along the newly generated nonce

Notes:

- This is required for static page optimisation and serving. In order to generate a fresh nonce on each request, we're using Cloudflare's HTMLRewriter API to intercept and rewrite the HTML
- The UUID in the `data-nonce` attribute is a randomly generated UUID for an extra layer of security. The worker specifically looks up on that UUID before performing rewrites. It also removes the data attribute before serving the page.

## Deployment

The commands below show how to deploy the worker to each environment of the project frontend.

Based on the environment which the worker is deployed, the worker is named differently and listens on different paths. See _wrangler.toml_ for the up-to-date name and path of the worker in each environment. 

```sh
# for development: project-frontend to pr4398-app.review.eng.dapperlabs.com/*
wrangler publish

# app-nonce-rewriter-review to *app.review.eng.dapperlabs.com/*
wrangler publish --env=review

# project-frontend-staging to app.staging.dapperlabs.com/*
wrangler publish --env=staging

# app-nonce-rewriter-beta to beta.staging.dapperlabs.com/*
wrangler publish --env=beta

# app-nonce-rewriter-production to www.staging.dapperlabs.com/*
wrangler publish --env=production
```

## Todo

- [ ] Rename repo to project-frontend-worker
- [ ] Do not explicitly specify worker `name` for each environment in _wrangler.toml_. Instead allow the worker name to be implicitly determined by the top-level name and environment name. _this is a best practice to avoid confusion_