defmodule Adoptoposs.TagsTest do
  use Adoptoposs.DataCase

  import Adoptoposs.Factory

  alias Adoptoposs.Tags

  describe "tags" do
    alias Adoptoposs.Tags.Tag

    @valid_attrs %{color: "some color", name: "some name", type: "some type"}
    @update_attrs %{color: "some updated color", name: "some updated name", type: "some updated type"}
    @invalid_attrs %{color: nil, name: nil, type: nil}

    test "list_tags/0 returns all tags" do
      tag = insert(:tag)
      assert Tags.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = insert(:tag)
      assert Tags.get_tag!(tag.id) == tag
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

      tags = Tags.upsert_tags(data)
      assert data = tags |> Enum.map(fn ({:ok, tag}) -> Map.from_struct(tag) end)
    end
  end

  describe "loader" do
    test "fetch_languages/1 fetches and compiles a list of programming language from the given file" do
      path = fixture_path!("languages.yml")

      assert [
        %{name: "CSS", type: "language", color: "#563d7c"},
        %{name: "Elixir", type: "language", color: "#6e4a7e"}
      ] = Tags.Loader.fetch_languages(path)
    end
  end
end
