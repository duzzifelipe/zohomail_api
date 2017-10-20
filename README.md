# ZohomailApi

ZohoMail is a great free option to use as your personal or company's email client. For companies, as we did, you can pick your own domain and have up to 25 users (also allows you to earn more 25 as referral bonus).
This repository isn't an official resource, but we use [https://www.zoho.com/mail/help/api/](their API) to quickly send emails.
Why using API and not SMPT? Some cloud hosting services (like Heroku, DigitalOcean and AWS) block SMTP ports and you need to ask them to allow it; it isn't so fast to do and scale.

## Installation

To get started, add `zohomail_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:zohomail_api, "~> 0.0.1"}]
end
```

### Generate your Access Token and get the AccountID
As it requires your email and password, you can generate it by yourself. But we did a helper to generate it by an easy way, just calling a task with your email and password.

Just run on your console:
```elixir
mix zoho.generate_credentials your@email.tld Y0urP455w0rD
```

### Then write some configuration
Now, you need to add these values you've got in your application configuration file.

Do it by the way you want, environment variables or plain text.

```
config :zohomail_api,
  access_token: xxxxxxxxxxxxxxx,
  account_id: 0000000000,
  from_address: my-zoho@email.com
```

### Send your email