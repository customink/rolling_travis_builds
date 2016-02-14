
<img width="100" src="https://cloud.githubusercontent.com/assets/2381/13034333/7596bc68-d300-11e5-8cef-ac82337378bf.gif">

## Rolling Travis Builds

Reduce the concurrent job load on your TravisCI pro plan using rolling builds by canceling older builds on the same branch(es). This is a template application that your organization can clone, configure, and deploy to Heroku. It focuses on:

* Receiving secure/verified webhooks from GitHub.
* API calls to TravisCI Pro to cancel duplicate builds.

Before deploying to Heroku, configure the following in `config/initializers/rolling_travis_builds.rb`:

* Webhook Secret
* Organization Name
* TravisCI Access Token

#### Configure Webhook Secret

The webhook secret will be used [verify GitHub payloads](https://developer.github.com/webhooks/securing/) as they come in. This ensures that only your organizations payloads can cancel builds. We suggest using `SecureRandom.hex(20)` to generate your secret key.

#### Configure TravisCI Access Token

It is best to use an organization admin when doing this.

* Go to your GitHub user "Settings" => "Personal access tokens" => "Generate new token".
* Create a token named "RollingTravisBuilds" with the selected (default) scopes.
  - repo (all)
  - user (all)
* Now run this curl command replacing `TOKEN_GENERATED_ABOVE` with the new GitHub token.

```
curl -X POST "https://api.travis-ci.com/auth/github" -d "github_token=TOKEN_GENERATED_ABOVE"
```

Take the value returned `{"github_token":"YOUR_GITHUB_TOKEN"}` and this is the app's new TravisCI access token. Set this variable in the `config.rolling_travis_builds.webhook_secret` in the applications initializer.

#### Deploy To Herok

Create a [named Heroku app](https://devcenter.heroku.com/articles/creating-apps) and deploy this app. Your secure Heroku URL will be used when creating webhooks for your repositories.

```
https://myorg-rollingtravisbuilds.herokuapp.com/webhook
```


## Repo Usage

To allow your project(s) to take advantage of this feature, add a Webhook to each repo that wants to take advantage of rolling builds. On your repo, navigate to Settings => Add Webhook then set the following:

* Payload URL: `https://myorg-rollingtravisbuilds.herokuapp.com/webhook`
* Content type: `application/json`
* Secret: `YOUR_SECRET_WEBHOOK_VALUE`
* Just the push event: `selected`

The secret token must be included. This is used to verify the application only responds to GitHub signed requests.


## Credits

Heavily inspired by [grosser/travis_dedup](https://github.com/grosser/travis_dedup) with an emphasis on TravisCI pro accounts and [verified GitHub payloads](https://developer.github.com/webhooks/securing/) for security.

