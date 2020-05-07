defmodule Adoptoposs.Jobs.Policy do
  # first 7 days of the week
  @first_week 1..7
  @third_week 15..21

  @doc """
  Authorizes to send monthly emails if the given date is the first
  `permitted_weekday` of the month.
  """
  def authorize(:send_emails_monthly, %Date{} = date, permitted_weekday) do
    date.day in @first_week && matches_weekday?(date, permitted_weekday)
  end

  @doc """
  Authorizes to send weekly emails if the given date is on the `permitted_weekday`.
  """
  def authorize(:send_emails_weekly, %Date{} = date, permitted_weekday) do
    matches_weekday?(date, permitted_weekday)
  end

  @doc """
  Authorizes to send biweekly emails if the given date is on the `permitted_weekday`.
  """
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
