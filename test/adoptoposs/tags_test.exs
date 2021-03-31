defmodule Adoptoposs.TagsTest do
  use Adoptoposs.DataCase

  import Adoptoposs.Factory

  alias Adoptoposs.Tags
  alias Adoptoposs.Network

  describe "policy" do
    test "create_tag_subscription is permitted if it doesn’t exist yet" do
      user = insert(:user)
      tag = insert(:tag)

      assert :ok = Bodyguard.permit(Tags, :create_tag_subscription, user, tag)
    end

    test "create_tag_subscription is forbidden if it already exists" do
      user = insert(:user)
      tag = insert(:tag)
      insert(:tag_subscription, user: user, tag: tag)

      assert {:error, :unauthorized} = Bodyguard.permit(Tags, :create_tag_subscription, user, tag)
    end

    test "delete_tag_subscription is permitted for own tag subscriptions" do
      user = insert(:user)
      tag = insert(:tag)
      tag_subscription = insert(:tag_subscription, user: user, tag: tag)

      assert :ok = Bodyguard.permit(Tags, :delete_tag_subscription, user, tag_subscription)
    end

    test "delete_tag_subscription is forbidden for other users’ tag subscriptions" do
      user = insert(:user)
      other_user = insert(:user)
      tag = insert(:tag)
      tag_subscription = insert(:tag_subscription, user: other_user, tag: tag)

      assert {:error, :unauthorized} =
               Bodyguard.permit(Tags, :delete_tag_subscription, user, tag_subscription)
    end
  end

  describe "tags" do
    alias Adoptoposs.Tags.{Tag, TagSubscription}

    @valid_attrs %{color: "some color", name: "some name", type: "some type"}
    @update_attrs %{
      color: "some updated color",
      name: "some updated name",
      type: "some updated type"
    }
    @invalid_attrs %{color: nil, name: nil, type: nil}

    test "list_language_tags/0 returns all tags of type language" do
      tag = insert(:tag, type: Tag.Language.type())
      insert(:tag)

      assert Tags.list_language_tags() == [tag]
    end

    test "list_published_project_tags/0 returns distinct tags of published projects" do
      tag_1 = insert(:tag, type: Tag.Language.type())
      tag_2 = insert(:tag, type: Tag.Language.type(), name: "b")
      tag_3 = insert(:tag, type: Tag.Language.type(), name: "a")
      insert(:tag, type: Tag.Language.type())

      insert_list(2, :project, language: tag_1)
      insert(:project, language: tag_2)
      insert(:project, language: tag_3)
      insert(:project, language: tag_3, status: :draft)

      assert Tags.list_published_project_tags() == [{tag_1, 2}, {tag_3, 1}, {tag_2, 1}]
    end

    test "list_recommended_tags/2 returns all tags that match the languages of a user's repos" do
      user = build(:user, provider: "github")
      {:ok, {_page_info, repos}} = Network.user_repos("token", user.provider, 3)

      repos = repos |> Enum.uniq_by(& &1.language.name)

      for repo <- repos do
        insert(:tag, type: Tag.Language.type(), name: String.upcase(repo.language.name))
      end

      insert(:tag)
      insert(:tag, type: Tag.Language.type())

      {:ok, tags} = Tags.list_recommended_tags(user, "token")

      assert Enum.count(tags) == Enum.count(repos)

      for {tag, index} <- Enum.with_index(tags) do
        language_name = Enum.at(repos, index).language.name
        assert String.downcase(language_name) == String.downcase(tag.name)
      end
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = insert(:tag)
      assert Tags.get_tag!(tag.id) == tag
    end

    test "get_tag_by_name!/1 return the tag with the given name" do
      tag = insert(:tag)

      assert Tags.get_tag_by_name!(tag.name) == tag
      assert Tags.get_tag_by_name!(String.upcase(tag.name)) == tag
    end

    test "get_tag_by_name!/1 returns the unknown tag if passing a nil name" do
      unknown_tag = Tags.Tag.Utility.unknown()
      tag = insert(:tag, name: unknown_tag.name)

      assert Tags.get_tag_by_name!(nil) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      assert {:ok, %Tag{} = tag} = Tags.create_tag(@valid_attrs)
      assert tag.color == "some color"
      assert tag.name == "some name"
      assert tag.type == "some type"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tags.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = insert(:tag)
      assert {:ok, %Tag{} = tag} = Tags.update_tag(tag, @update_attrs)
      assert tag.color == "some updated color"
      assert tag.name == "some updated name"
      assert tag.type == "some updated type"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = insert(:tag)
      assert {:error, %Ecto.Changeset{}} = Tags.update_tag(tag, @invalid_attrs)
      assert tag == Tags.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = insert(:tag)
      assert {:ok, %Tag{}} = Tags.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = insert(:tag)
      assert %Ecto.Changeset{} = Tags.change_tag(tag)
    end

    test "upsert_tags/1 inserts a Tag for all given new attrs" do
      data = [
        %{name: "CSS", type: "language", color: "#563d7c"},
        %{name: "Elixir", type: "language", color: "#6e4a7e"}
      ]

      tags = Tags.upsert_tags(data) |> Enum.map(fn {:ok, tag} -> tag end)

      assert tags |> Enum.map(&Map.take(&1, [:name, :type, :color])) == data
    end

    test "list_user_tag_subscriptions/1 returns all tag subscriptions for a user" do
      user = insert(:user)
      tag = insert(:tag)
      other_tag = insert(:tag)
      tag_subscription_1 = insert(:tag_subscription, user: user, tag: tag)
      tag_subscription_2 = insert(:tag_subscription, user: user, tag: other_tag)
      tag_subscription_3 = insert(:tag_subscription, tag: tag)

      tag_subscriptions = Tags.list_user_tag_subscriptions(user)
      loaded_ids = tag_subscriptions |> Enum.map(& &1.id)

      assert tag_subscription_1.id in loaded_ids
      assert tag_subscription_2.id in loaded_ids
      refute tag_subscription_3.id in loaded_ids
    end

    test "get_tag_subscription!/2 returns the tag_subscription for the given user and tag" do
      %{id: id, tag_id: tag_id} = insert(:tag_subscription)
      assert %TagSubscription{id: ^id, tag_id: ^tag_id} = Tags.get_tag_subscription!(id)
    end

    test "create_tag_subscription/2 creates a tag subscription with valid data" do
      user = insert(:user)
      tag = insert(:tag)
      attrs = %{user_id: user.id, tag_id: tag.id}

      assert {:ok, tag_subscription} = Tags.create_tag_subscription(attrs)
      assert user.id == tag_subscription.user_id
      assert tag.id == tag_subscription.tag_id
    end

    test "create_tag_subscription/2 does not create a subscription if it exists" do
      user = insert(:user)
      tag = insert(:tag)
      insert(:tag_subscription, user: user, tag: tag)
      attrs = %{user_id: user.id, tag_id: tag.id}

      assert {:error,
              %{
                errors: [
                  tag_subscriptions:
                    {"has already been taken",
                     [
                       constraint: :unique,
                       constraint_name: "tag_subscriptions_user_id_tag_id_index"
                     ]}
                ]
              }} = Tags.create_tag_subscription(attrs)
    end

    test "delete_tag_subscription/2 removes a tag subscription" do
      user = insert(:user)
      tag = insert(:tag)
      tag_subscription = insert(:tag_subscription, user: user, tag: tag)

      assert {:ok, tag_subscription} = Tags.delete_tag_subscription(tag_subscription)
      assert user.id == tag_subscription.user_id
      assert tag.id == tag_subscription.tag_id
      assert TagSubscription |> Repo.get(tag_subscription.id) == nil
    end

    test "create_tag_subscriptions/2 bulk insert tags for the given user" do
      user = insert(:user)
      tags = insert_list(2, :tag, type: Tag.Language.type())
      attrs = tags |> Enum.map(&%{user_id: user.id, tag_id: &1.id})

      tag_subscriptions = Tags.create_tag_subscriptions(attrs)

      for tag_subscription <- tag_subscriptions do
        assert {:ok, _} = tag_subscription
      end
    end
  end

  describe "loader" do
    alias Adoptoposs.Tags.Tag

    test "fetch_languages/1 fetches and compiles a list of programming language from the given file" do
      path = fixture_path!("languages.yml")

      assert [
               %Tag{name: "CSS", type: "language", color: "#563d7c"},
               %Tag{name: "Elixir", type: "language", color: "#6e4a7e"}
             ] = Tags.Loader.fetch_languages(path)
    end
  end
end
