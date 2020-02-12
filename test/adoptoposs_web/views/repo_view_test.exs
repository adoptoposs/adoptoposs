defmodule AdoptopossWeb.RepoViewTest do
  use AdoptopossWeb.ConnCase, async: true

  alias AdoptopossWeb.RepoView

  describe "selected_attr/2" do
    test "returns nil if passed arguments are not equal" do
      assert RepoView.selected_attr(:this, :that) == nil
    end

    test "returns :selected if passed arguments are equal" do
      assert RepoView.selected_attr(:this, :this) == :selected
    end
  end
end
