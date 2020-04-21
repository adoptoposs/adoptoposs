defmodule Adoptoposs.Mjml do
  @moduledoc """
  Utility module to render mjml content to HTML content.
  """

  @executable "../assets/node_modules/mjml"

  @doc """
  Compiles the given mjml to HTML text.

  ## Examples

      iex> render("<mj-html></mj-html>")
      "<!doctype html>\n<html xmlns=…"

      iex> render("not-mjml")
      (RuntimeError) mjml exited with status 1: …
  """
  def render(mjml) do
    case compile(mjml) do
      {html, 0} -> String.trim(html)
      {error, status} -> raise "mjml exited with status #{status}: #{error}"
    end
  end

  defp compile(mjml) do
    System.cmd("node", [Path.expand("bin/mjml.js"), mjml])
  end
end
