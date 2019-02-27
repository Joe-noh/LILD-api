defmodule LILD.DreamsTest do
  use LILD.DataCase

  alias LILD.Dreams

  describe "dreams" do
    alias LILD.Dreams.Dream

    @valid_attrs %{body: "some body", date: ~D[2010-04-17], draft: true, secret: true}
    @update_attrs %{body: "some updated body", date: ~D[2011-05-18], draft: false, secret: false}
    @invalid_attrs %{body: nil, date: nil, draft: nil, secret: nil}

    def dream_fixture(attrs \\ %{}) do
      {:ok, dream} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dreams.create_dream()

      dream
    end

    test "list_dreams/0 returns all dreams" do
      dream = dream_fixture()
      assert Dreams.list_dreams() == [dream]
    end

    test "get_dream!/1 returns the dream with given id" do
      dream = dream_fixture()
      assert Dreams.get_dream!(dream.id) == dream
    end

    test "create_dream/1 with valid data creates a dream" do
      assert {:ok, %Dream{} = dream} = Dreams.create_dream(@valid_attrs)
      assert dream.body == "some body"
      assert dream.date == ~D[2010-04-17]
      assert dream.draft == true
      assert dream.secret == true
    end

    test "create_dream/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dreams.create_dream(@invalid_attrs)
    end

    test "update_dream/2 with valid data updates the dream" do
      dream = dream_fixture()
      assert {:ok, %Dream{} = dream} = Dreams.update_dream(dream, @update_attrs)
      assert dream.body == "some updated body"
      assert dream.date == ~D[2011-05-18]
      assert dream.draft == false
      assert dream.secret == false
    end

    test "update_dream/2 with invalid data returns error changeset" do
      dream = dream_fixture()
      assert {:error, %Ecto.Changeset{}} = Dreams.update_dream(dream, @invalid_attrs)
      assert dream == Dreams.get_dream!(dream.id)
    end

    test "delete_dream/1 deletes the dream" do
      dream = dream_fixture()
      assert {:ok, %Dream{}} = Dreams.delete_dream(dream)
      assert_raise Ecto.NoResultsError, fn -> Dreams.get_dream!(dream.id) end
    end

    test "change_dream/1 returns a dream changeset" do
      dream = dream_fixture()
      assert %Ecto.Changeset{} = Dreams.change_dream(dream)
    end
  end
end
