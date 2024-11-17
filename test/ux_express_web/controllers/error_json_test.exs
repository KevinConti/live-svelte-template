defmodule UxExpressWeb.ErrorJSONTest do
  use UxExpressWeb.ConnCase, async: true

  test "renders 404" do
    assert UxExpressWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert UxExpressWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
