defmodule AdoptopossWeb.PageView do
  use AdoptopossWeb, :view

  def faq(question, do: answer) do
    render("faq_item.html", question: question, answer: answer)
  end
end
