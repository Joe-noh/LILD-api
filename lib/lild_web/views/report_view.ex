defmodule LILDWeb.ReportView do
  use LILDWeb, :view

  def render("show.json", %{report: report}) do
    %{report: render_one(report, __MODULE__, "report.json")}
  end

  def render("report.json", %{report: report}) do
    %{user_id: report.user_id, dream_id: report.dream_id}
  end
end
