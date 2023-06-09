defmodule Adoptoposs.Accounts.UserFromAuth do
  alias Ueberauth.Auth
  alias Adoptoposs.UriHelper

  def build(%Auth{} = auth) do
    %{
      uid: "#{auth.uid}",
      provider: "#{auth.provider}",
      name: name_from_auth(auth),
      username: username_from_auth(auth),
      email: email_from_auth(auth),
      avatar_url: avatar_url_from_auth(auth),
      profile_url: profile_url_from_auth(auth),
      settings: %{}
    }
  end

  defp name_from_auth(%Auth{info: %{name: name}}) when name != nil, do: name

  defp name_from_auth(%Auth{info: info} = auth) do
    if is_nil(info.first_name) && is_nil(info.last_name) do
      username_from_auth(auth)
    else
      [info.first_name, info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))
      |> Enum.join(" ")
    end
  end

  defp username_from_auth(%Auth{info: %{nickname: nickname}}), do: nickname
  defp username_from_auth(%Auth{}), do: ""

  defp avatar_url_from_auth(%Auth{info: %{urls: %{avatar_url: url}}}),
    do: UriHelper.extend_path(url, s: 80)

  defp avatar_url_from_auth(%Auth{}), do: ""

  defp email_from_auth(%Auth{info: %{email: email}}), do: email
  defp email_from_auth(%Auth{}), do: ""

  defp profile_url_from_auth(%Auth{info: %{urls: %{html_url: url}}}), do: url
  defp profile_url_from_auth(%Auth{}), do: ""
end
