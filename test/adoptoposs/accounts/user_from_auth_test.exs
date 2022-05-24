defmodule Adoptoposs.Accounts.UserFromAuthTest do
  use Adoptoposs.DataCase

  import Adoptoposs.Factory

  alias Adoptoposs.Accounts.UserFromAuth

  test "build/1 builds user data from the passed Auth" do
    auth = build(:auth)

    assert UserFromAuth.build(auth) == %{
             uid: auth.uid,
             provider: auth.provider,
             name: auth.info.name,
             username: auth.info.nickname,
             email: auth.info.email,
             avatar_url: auth.info.urls.avatar_url,
             profile_url: auth.info.urls.html_url,
             settings: %{}
           }
  end

  test "build/1 uses first_name & last_name if name is not available" do
    auth = build(:auth)
    info = %{auth.info | name: nil, first_name: "Peter", last_name: "Parker"}
    auth = %{auth | info: info}

    assert UserFromAuth.build(auth) == %{
             uid: auth.uid,
             provider: auth.provider,
             name: "#{auth.info.first_name} #{auth.info.last_name}",
             username: auth.info.nickname,
             email: auth.info.email,
             avatar_url: auth.info.urls.avatar_url,
             profile_url: auth.info.urls.html_url,
             settings: %{}
           }
  end

  test "build/1 uses username as name if names are not available" do
    auth = build(:auth)
    info = %{auth.info | name: nil, first_name: nil, last_name: nil}
    auth = %{auth | info: info}

    assert UserFromAuth.build(auth) == %{
             uid: auth.uid,
             provider: auth.provider,
             name: auth.info.nickname,
             username: auth.info.nickname,
             email: auth.info.email,
             avatar_url: auth.info.urls.avatar_url,
             profile_url: auth.info.urls.html_url,
             settings: %{}
           }
  end
end
