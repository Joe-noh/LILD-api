defmodule LILDWeb.User.Dream.ReportController do
  use LILDWeb, :controller

  alias LILD.{Dreams, Accounts}
  alias LILD.Dreams.Report

  plug LILDWeb.RequireLoginPlug
  plug :assign_user
  plug :assign_dream

  action_fallback LILDWeb.FallbackController

  def create(conn, _params) do
    %{current_user: current_user, dream: dream} = conn.assigns

    with {:ok, %Report{} = report} <- Dreams.report_dream(current_user, dream) do
      conn
      |> put_status(:created)
      |> put_view(LILDWeb.ReportView)
      |> render("show.json", report: report)
    else
      _ -> {:error, :bad_request}
    end
  end

  defp assign_user(conn, _) do
    assign(conn, :user, Accounts.get_user!(conn.params["user_id"]))
  end

  defp assign_dream(conn, _) do
    assign(conn, :dream, Dreams.get_dream!(conn.assigns.user, conn.params["dream_id"]))
  end
end
