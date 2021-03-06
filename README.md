# ZohomailApi

ZohoMail is a great free option to use as your personal or company's email client. For companies, as we did, you can pick your own domain and have up to 25 users (also allows you to earn more 25 as referral bonus).
This repository isn't an official resource, but we use [https://www.zoho.com/mail/help/api/](their API) to quickly send emails.
Why using API and not SMPT? Some cloud hosting services (like Heroku, DigitalOcean and AWS) block SMTP ports and you need to ask them to allow it; it isn't so fast to do and scale.

## Installation

To get started, add `zohomail_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:zohomail_api, "~> 0.0.2"}]
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
Send an email from your controller.
If you didn't set `from_address` on your configuration file, you can specify as the last argument of send function (optional).

```
ZohomailApi.send("destination@email.com", "Email Subject", "<h1>HTML Content</h1>", "fromAdress@if-not.set")
```

### Todo
I created this repository because I had a lot of problems to send a Zoho mail using elixir, maily to generate the credentials. Also, Zoho mail documentation seems imcomplete.
There are more things to be done that I don't need by now or I didn't finished:
  - Post tests (I don't know how to do it without exposing my keys, so they weren't uploaded);
  - More options like sending attachments and CC;
  - Receive emails;
  - Render HTML.

### HTML Rendering
Nowadays there isn't an easy way to render an HTML template (.eex).
But you can follow these steps to get it:

Create a view and a template folder containing your templates as you do with Phoenix templates.
```
defmodule MyProj.EmailView do
  use MyProj, :view
end
```

Then, while sending your email, you can call a View-to-string method:
```
ZohomailApi.send(
  "destination@email.com", 
  "Email Subject",
  Phoenix.View.render_to_string(MyProj.EmailView, "email-template.html", [conn: conn, custom_data: %{}])
  )
```