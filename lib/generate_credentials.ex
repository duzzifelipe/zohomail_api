defmodule Mix.Tasks.GenerateCredentials do
  @moduledoc """
  This module will generate an API key to use with ZohoMail Send API
  """

  use Mix.Task

  @doc """
  Receive user's credentials and then request an access token
  """
  def run([email, password]) when is_binary(email) and is_binary(password) do
    request_access_token(email, password)
  end

  defp request_access_token(email, password) do
    HTTPotion.start()

    # get zoho URL and call with auth parameters
    Application.get_env(:zohomail_api, :auth_endpoint)
    |> HTTPotion.get(query: %{"SCOPE": "ZohoMail/ZohoMailAPI", "EMAIL_ID": email, "PASSWORD": password})
    |> parse_response
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
end
