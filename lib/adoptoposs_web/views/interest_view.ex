defmodule AdoptopossWeb.InterestView do
  use AdoptopossWeb, :view

  alias Adoptoposs.Dashboard.Project
  alias Adoptoposs.Communication.Interest

  @doc """
  Returns the reply email subject for an interest.
  """
  def email_subject(%Project{name: name}) do
    "[Adoptoposs][#{name}] Thank you for your message!"
  end

  @doc """
  Returns the reply email body for an interest.
  The original message of the interest is quoted in the body text.
  """
  def email_body(%Interest{} = interest) do
    __MODULE__
    |> render("reply", interest: interest)
    |> URI.encode()
  end
end
