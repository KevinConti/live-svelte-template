defmodule UxExpress.Repo do
  use Ecto.Repo,
    otp_app: :ux_express,
    adapter: Ecto.Adapters.Postgres
end
