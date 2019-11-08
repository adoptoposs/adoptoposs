defmodule Adoptoposs.AccountsTest do
  use Adoptoposs.DataCase

  alias Adoptoposs.Accounts

  describe "users" do
    alias Adoptoposs.Accounts.User
    alias Ueberauth.Auth

    @valid_attrs %{
      avatar_url: "some avatar_url",
      email: "some email",
      name: "some name",
      profile_url: "some profile_url",
      provider: "some_provider",
      uid: "123456789",
      username: "some username"
    }
    @update_attrs %{
      avatar_url: "some updated avatar_url",
      email: "some updated email",
      name: "some updated name",
      profile_url: "some updated profile_url",
      provider: "some updated provider",
      uid: "some updated uid",
      username: "some updated username"
    }
    @invalid_attrs %{
      avatar_url: nil,
      email: nil,
      name: nil,
      profile_url: nil,
      provider: nil,
      uid: nil,
      username: nil
    }
    @valid_auth %Auth{
      uid: 123_456_789,
      provider: :some_provider,
      info: %{
        name: "some name",
        nickname: "some username",
        email: "some email",
        first_name: nil,
        last_name: nil,
        urls: %{avatar_url: "some avatar_url", html_url: "some profile_url"}
      }
    }
    @invalid_auth %Auth{
      uid: nil,
      provider: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_auth/1 returns the user with the given uid and provider" do
      user = user_fixture()
      assert Accounts.get_user_by_auth(@valid_auth) == user
    end

    test "get_user_by_auth/1 returns nil if there is not user matching the given auth" do
      assert Accounts.get_user_by_auth(@invalid_auth) == nil
    end

    test "upsert_user!/2 for missing user creates the user" do
      assert {:ok, %User{} = user} = Accounts.upsert_user(@valid_auth)
      assert user.avatar_url == "some avatar_url"
      assert user.email == "some email"
      assert user.name == "some name"
      assert user.profile_url == "some profile_url"
      assert user.provider == "some_provider"
      assert user.uid == "123456789"
      assert user.username == "some username"
    end

    test "upsert_user!/2 for available user updates the user" do
      user_fixture()
      new_info = Map.merge(@valid_auth.info, %{email: "#{@valid_attrs.email}, but new"})
      new_attrs = Map.merge(@valid_auth, %{info: new_info})

      assert {:ok, %User{} = user} = Accounts.upsert_user(new_attrs)
      assert user.avatar_url == "some avatar_url"
      assert user.email == "some email, but new"
      assert user.name == "some name"
      assert user.profile_url == "some profile_url"
      assert user.provider == "some_provider"
      assert user.uid == "123456789"
      assert user.username == "some username"
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.avatar_url == "some avatar_url"
      assert user.email == "some email"
      assert user.name == "some name"
      assert user.profile_url == "some profile_url"
      assert user.provider == "some_provider"
      assert user.uid == "123456789"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.avatar_url == "some updated avatar_url"
      assert user.email == "some updated email"
      assert user.name == "some updated name"
      assert user.profile_url == "some updated profile_url"
      assert user.provider == "some updated provider"
      assert user.uid == "some updated uid"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
