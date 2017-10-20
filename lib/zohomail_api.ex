defmodule ZohomailApi.BodyData do
  @derive [Poison.Encoder]
  defstruct [toAddress: nil, subject: nil, content: nil, fromAddress: nil]
end

defmodule ZohomailApi.ZohomailResponse do
  defstruct [
    status: [code: nil, description: nil],
    data: [subject: nil, fromAddress: nil, toAddress: nil, content: nil]
  ]
end

defmodule ZohomailApi do
  @moduledoc """
  Send an email using ZohoMail API
  """

  @doc """
  Load account information and call send-mail with passed arguments
  """
  def send(to, subject, content, from_address \\ nil) do
    # Load environment variables
    access_token = Application.get_env(:zohomail_api, :access_token)
    account_id = Application.get_env(:zohomail_api, :account_id)

    # Checks for from_address (that can be set at config file)
    from_address =
      if is_nil(from_address) do
        Application.get_env(:zohomail_api, :from_address)
      else
        from_address
      end

    if is_nil(access_token) || is_nil(account_id) || is_nil(from_address) do
      # if there is no configured data, do nothing
      {:error, :invalid_access_data}
    else
      # build resource url and call send function
      resource = Application.get_env(:zohomail_api, :api_endpoint) <> "/accounts/" <> account_id <> "/messages"
      # generate authentication header
      headers = ["Authorization": "Zoho-authtoken #{access_token}", "Accept": "Application/json; Charset=utf-8"]
      # post data
      data = Poison.encode!(%ZohomailApi.BodyData{toAddress: to, subject: subject, content: content, fromAddress: from_address})
      # post the message
      HTTPotion.post(resource, [body: data, headers: headers])
      |> parse_callback()
    end
  end

  # parse http body response to a struct
  defp parse_callback(%{body: body}) do
    %{"data" => data, "status" => status} = Poison.decode!(body)
    %ZohomailApi.ZohomailResponse{status: status, data: data}
  end
end
