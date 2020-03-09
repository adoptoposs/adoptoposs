defmodule Adoptoposs.Dashboard.Policy do
  @behaviour Bodyguard.Policy

  alias Adoptoposs.Accounts.User
  alias Adoptoposs.Dashboard.Project

  def authorize(action, %User{id: user_id}, %Project{user_id: user_id})
      when action in [:show_project, :update_project, :delete_project],
      do: :ok

  def authorize(action, %User{}, %Project{})
      when action in [:show_project, :update_project, :delete_project],
      do: :error
end
