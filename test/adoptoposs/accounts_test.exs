defmodule Adoptoposs.AccountsTest do
  use Adoptoposs.DataCase

  import Adoptoposs.Factory

  alias Adoptoposs.Accounts
  alias Adoptoposs.Accounts.{User, Settings}

  describe "settings" do
    test "email_when_contact_values/0 return all allowed values" do
      assert Settings.email_when_contacted_values() == ~w(immediately off)
    end

    test "email_project_recommendations/0 return all allowed values" do
      assert Settings.email_project_recommendations_values() == ~w(weekly biweekly monthly off)
    end
  end

  describe "accounts" do
    test "get_user/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user(user.id) == user
    end

    test "get_user/1 returns nil for a missing id" do
      assert Accounts.get_user(-1) == nil
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user!/1 allows preloading assocs" do
      user = insert(:user)
      fetched_user = Accounts.get_user!(user.id, preload: [:interests])
      assert fetched_user.interests == []
    end

    test "get_user!/1 raises error for a missing id" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "get_user_by_auth/1 returns the user with the given uid and provider" do
      user = insert(:user)
      auth = build(:auth, uid: user.uid, provider: user.provider)
      assert Accounts.get_user_by_auth(auth) == user
    end

    test "get_user_by_auth/1 returns nil if there is no user matching the given auth" do
      auth = build(:auth)
      assert Accounts.get_user_by_auth(auth) == nil
    end

    test "get_user_by_auth/1 returns nil for auths without a uid" do
      auth = build(:auth, uid: nil)
      assert Accounts.get_user_by_auth(auth) == nil
    end

    test "get_user_by_auth/1 returns nil for auths without a provider" do
      auth = build(:auth, provider: nil)
      assert Accounts.get_user_by_auth(auth) == nil
    end

    test "upsert_user!/2 for missing user creates the user" do
      auth = build(:auth)

      %{
        uid: uid,
        provider: provider,
        info: %{
          email: email,
          name: name,
          nickname: nickname,
          urls: %{avatar_url: avatar_url, html_url: html_url}
        }
      } = auth

      assert {:ok,
              %User{
                uid: ^uid,
                provider: ^provider,
                email: ^email,
                name: ^name,
                username: ^nickname,
                avatar_url: ^avatar_url,
                profile_url: ^html_url
              }} = Accounts.upsert_user(auth)
    end

    test "upsert_user!/2 for available user updates the user" do
      %User{id: id, uid: uid, provider: provider} = insert(:user)
      auth = build(:auth, uid: uid, provider: provider)

      %{
        info: %{
          email: email,
          name: name,
          nickname: nickname,
          urls: %{avatar_url: avatar_url, html_url: html_url}
        }
      } = auth

      assert {:ok,
              %User{
                id: ^id,
                uid: ^uid,
                provider: ^provider,
                email: ^email,
                name: ^name,
                username: ^nickname,
                avatar_url: ^avatar_url,
                profile_url: ^html_url
              }} = Accounts.upsert_user(auth)
    end

    test "upsert_user!/2 with valid data creates a user" do
      attrs = build(:user) |> Map.from_struct()

      %{
        uid: uid,
        provider: provider,
        email: email,
        name: name,
        username: username,
        avatar_url: avatar_url,
        profile_url: profile_url
      } = attrs

      assert {:ok,
              %User{
                uid: ^uid,
                provider: ^provider,
                email: ^email,
                name: ^name,
                username: ^username,
                avatar_url: ^avatar_url,
                profile_url: ^profile_url
              }} = Accounts.create_user(attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      attrs = build(:user, uid: nil, provider: nil) |> Map.from_struct()
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = %User{id: id} = insert(:user)
      attrs = build(:user) |> Map.from_struct()

      %{
        uid: uid,
        provider: provider,
        email: email,
        name: name,
        username: username,
        avatar_url: avatar_url,
        profile_url: profile_url
      } = attrs

      assert {:ok,
              %User{
                id: ^id,
                uid: ^uid,
                provider: ^provider,
                email: ^email,
                name: ^name,
                username: ^username,
                avatar_url: ^avatar_url,
                profile_url: ^profile_url
              }} = Accounts.update_user(user, attrs)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      attrs = build(:user, uid: nil, provider: nil) |> Map.from_struct()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "update_settings/2 with valid data updates a user's settings" do
      combinations =
        for a <- Settings.email_when_contacted_values(),
            b <- Settings.email_project_recommendations_values(),
            do: [a, b]

      for [a, b] <- combinations do
        user = insert(:user, settings: %{})

        attrs = %{
          email_when_contacted: a,
          email_project_recommendations: b
        }

        assert {:ok, %User{settings: settings}} = Accounts.update_settings(user, attrs)

        assert %{
                 email_when_contacted: ^a,
                 email_project_recommendations: ^b
               } = settings
      end
    end

    test "update_settings/2 with invalid data returns error changeset" do
      user = insert(:user, settings: %{})
      attrs = %{email_when_contacted: "invalid"}

      assert {:error, _changeset} = Accounts.update_settings(user, attrs)
    end
  end
end
