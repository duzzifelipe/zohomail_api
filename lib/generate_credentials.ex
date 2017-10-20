defmodule Mix.Tasks.Zoho.GenerateCredentials do
  @moduledoc """
  This module will generate an API key to use with ZohoMail Send API
  """

  use Mix.Task

  @auth_endpoint "https://accounts.zoho.com/apiauthtoken/nb/create"
  @api_endpoint "https://mail.zoho.com/api"

  @doc """
  Receive user's credentials and then request an access token
  """
  def run([email, password]) when is_binary(email) and is_binary(password) do
    request_access_token(email, password)
  end

  @doc """
  Receive only 1 variable and show an error
  """
  def run(_) do
    Mix.shell.info("\nError: Provide 2 variables (email + password)")
  end

  defp request_access_token(email, password) do
    HTTPotion.start()

    # get zoho URL and call with auth parameters
    HTTPotion.get(@auth_endpoint, query: %{"SCOPE": "ZohoMail/ZohoMailAPI", "EMAIL_ID": email, "PASSWORD": password})
    |> parse_response()
  end

  #  Zoho does not answer using JSON. So, interpret their text message.
  #
  #  Error example:
  #  #
  #  #Thu Oct 19 07:16:31 PDT 2017
  #  CAUSE=null
  #  RESULT=FALSE
  #
  #  Success example:
  #  #
  #  #Thu Oct 19 07:21:45 PDT 2017
  #  AUTHTOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  #  RESULT=TRUE
  #
  #  So, if fourth line is true, return the authtoken
  #  Otherwise, return lowercase cause atom
  defp parse_response(%{body: body, headers: _}) do
    body
    |> String.split("\n")
    |> Enum.slice(2, 2)
    |> reduce_list()
    |> is_ok_get_account()
    |> IO.inspect()
  end

  defp reduce_list(keys) do
    # run over each list on the list
    Enum.map(keys, fn (item) ->
      # divide tem on the = sign and return a tuple with atom key
      tuple =
        item
        |> String.split("=")
        |> List.to_tuple()

      # arrange the tuple key to an atom
      key =
        elem(tuple, 0)
        |> String.downcase()
        |> String.to_atom()

      # call a function to change key value
      arrange_value(key, elem(tuple, 1))
    end)
    |> to_tuple()
  end

  # This function receives each key-value from reduce_list
  #
  # Two important conversions are made:
  #   - if given key is 'result', convert data to boolean
  #   - if key is 'cause', an error, convert it to an atom
  #   - otherwise, the last option is 'authtoken', the string we want
  defp arrange_value(key, data) do
    data =
      case key do
        :result ->
          data
          |> String.downcase()
          |> String.to_existing_atom()
        :cause ->
          data
          |> String.downcase()
          |> String.to_atom()
        :authtoken -> data
      end

    # return a tuple
    {key, data}
  end

  defp to_tuple(list) do
    case list do
      [cause: cause, result: false] -> {:error, cause}
      [authtoken: token, result: true] -> {:ok, token}
    end
  end

  # parse the result of previous function
  # that could be:
  # {:ok, "tokenstring"}
  # {:error, :err_msg_atom}
  # and, if is ok, call API endpoint to get account ID
  defp is_ok_get_account({status, data}) do
    case status do
      :ok -> get_account(data)
      :error -> {:error, data}
    end
  end

  defp get_account(access_token) do
    # define auth header
    headers = ["Authorization": "Zoho-authtoken #{access_token}", "Accept": "Application/json; Charset=utf-8"]
    # get url and then call Zoho API
    HTTPotion.get(@api_endpoint <> "/accounts", headers: headers, timeout: 10_000)
    |> parse_account_response(access_token)
  end

  defp parse_account_response(%{body: body}, access_token) do
    case Poison.decode(body) do
      {:ok, %{"status" => %{"code" => _, "description" => "success"}, "data" => [data]}} ->
        {:ok, [access_token: access_token, account_id: Map.get(data, "accountId", "")]}
      {:ok, %{"status" => %{"code" => _, "description" => "Invalid Input"}, "data" => _}} ->
        {:error, :invalid_generated_token}
      {:error, _} ->
        {:error, :mal_formed_json}
    end
  end
end
