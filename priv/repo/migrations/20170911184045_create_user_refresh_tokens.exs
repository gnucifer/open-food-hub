defmodule Ofh.Repo.Migrations.CreateUserRefreshTokens do
  use Ecto.Migration

  # TODO: Add unique constraint on resource_name, resource_id
  def change do
    create table(:user_refresh_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :expiry_date, :integer
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    unique_index(:user_refersh_tokens, [:user_id])
  end
end
