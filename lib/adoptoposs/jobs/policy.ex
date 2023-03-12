defmodule Adoptoposs.Jobs.Policy do
  @moduledoc """
  Policy for authorizing Job actions.

  ### Sending emails in the given interval

  Available actions are:

  * `:send_emails_monthly`: Authorizes to send monthly emails if the given date
    is the first `permitted_weekday` of the month.
  * `:send_emails_weekly`: Authorizes to send weekly emails if the given date is
    on the `permitted_weekday`.
  * `:send_emails_biweekly`: Authorizes to send biweekly emails if the given date
    is on the `permitted_weekday`.

  """

  # first 7 days of the week
  @first_week 1..7
  @third_week 15..21

  def authorize(:send_emails_monthly, %Date{} = date, permitted_weekday) do
    date.day in @first_week && matches_weekday?(date, permitted_weekday)
  end

  def authorize(:send_emails_weekly, %Date{} = date, permitted_weekday) do
    matches_weekday?(date, permitted_weekday)
  end

  def authorize(:send_emails_biweekly, %Date{} = date, permitted_weekday) do
    day = date.day

    (day in @first_week || day in @third_week) && matches_weekday?(date, permitted_weekday)
  end

  def authorize(_, _, _), do: :error

  defp matches_weekday?(date, weekday) when is_integer(weekday) do
    Timex.weekday(date) == weekday
  end

  defp matches_weekday?(date, weekday) when is_binary(weekday) do
    to_string(Timex.weekday(date)) == weekday
  end

  defp matches_weekday?(_date, _weekday), do: false
end
